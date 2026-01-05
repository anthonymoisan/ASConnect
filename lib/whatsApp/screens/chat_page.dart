// lib/whatsApp/screens/chat_page.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../models/chat_message.dart';
import '../services/conversation_api.dart';
import '../services/conversation_events.dart';

class ChatPage extends StatefulWidget {
  final int conversationId;
  final int currentPersonId;

  const ChatPage({
    super.key,
    required this.conversationId,
    required this.currentPersonId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<ChatMessage> _messages = [];
  bool _initialLoading = true;

  late final Future<String?> _otherPseudoFuture;

  bool _sending = false;
  ChatMessage? _replyToMessage;
  bool _didInitialScroll = false;

  // ✅ Polling
  Timer? _pollTimer;
  bool _pollingEnabled = true;
  static const Duration _pollInterval = Duration(seconds: 6);

  bool _reloading = false;

  // ✅ throttling read-sync
  DateTime? _lastReadSyncAt;
  static const Duration _readSyncMinInterval = Duration(seconds: 2);

  // ✅ Scroll intelligent state
  bool _userScrollingUp = false; // when true: do not autoscroll
  bool _forceScrollAfterNextReload = false; // used after send/reply

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _otherPseudoFuture = ConversationApi.fetchOtherMemberPseudo(
      conversationId: widget.conversationId,
      currentPersonId: widget.currentPersonId,
    );

    _loadInitial();
    _startPolling();
  }

  @override
  void dispose() {
    _stopPolling();
    WidgetsBinding.instance.removeObserver(this);

    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _pollingEnabled = true;
      _startPolling();
      _reloadMessages(scrollIfAtBottom: true);
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _pollingEnabled = false;
      _stopPolling();
    }
  }

  void _startPolling() {
    if (!_pollingEnabled) return;
    if (_pollTimer != null) return;

    _pollTimer = Timer.periodic(_pollInterval, (_) async {
      if (!mounted) return;
      await _reloadMessages(scrollIfAtBottom: true);
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  bool _isMine(ChatMessage msg) => msg.senderPeopleId == widget.currentPersonId;

  bool _isDeleted(ChatMessage msg) {
    final txt = msg.bodyText.trim().toLowerCase();
    return txt == 'message supprimé';
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatTime(DateTime date) {
    final hh = date.hour.toString().padLeft(2, '0');
    final mm = date.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  String _formatDayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    final diff = today.difference(d).inDays;

    if (diff == 0) return 'Aujourd’hui';
    if (diff == 1) return 'hier';

    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final yyyy = date.year.toString();
    return '$dd/$mm/$yyyy';
  }

  bool _isAtBottom({double threshold = 80}) {
    if (!_scrollController.hasClients) return true;
    final pos = _scrollController.position;
    final distanceFromBottom = pos.maxScrollExtent - pos.pixels;
    return distanceFromBottom <= threshold;
  }

  void _scrollToBottom({bool animated = false}) {
    if (!_scrollController.hasClients) return;
    final target = _scrollController.position.maxScrollExtent;
    if (animated) {
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(target);
    }
  }

  /// ✅ Robust scroll: waits for the ListView to be attached.
  /// If controller has no clients on this frame, it retries on the next frame.
  void _scheduleScrollToBottom({bool animated = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (!_scrollController.hasClients) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _scrollToBottom(animated: animated);
        });
        return;
      }

      _scrollToBottom(animated: animated);
    });
  }

  // ✅ Hash stable pour détecter bodyText changes (edit/delete)
  int _hashStr(String s) {
    final bytes = utf8.encode(s);
    int h = 0;
    for (final b in bytes) {
      h = (h * 31) ^ b;
    }
    return h;
  }

  // ✅ Signature robuste (inclut bodyText => detect edit/delete immediately)
  int _messagesSignature(List<ChatMessage> list) {
    int sig = list.length;
    for (final m in list) {
      sig = (sig * 31) ^ m.id;
      sig = (sig * 31) ^ (m.senderPeopleId ?? 0);
      sig = (sig * 31) ^ _hashStr(m.bodyText);
      sig = (sig * 31) ^ (m.createdAt.millisecondsSinceEpoch);
      sig = (sig * 31) ^ (m.editedAt?.millisecondsSinceEpoch ?? 0);
      sig = (sig * 31) ^ (m.replyToMessageId ?? 0);
      sig = (sig * 31) ^ _hashStr(m.replyBodyText ?? '');
      sig = (sig * 31) ^ m.reactions.length;
      sig = (sig * 31) ^ ((m.isSeen == true) ? 1 : 0);
    }
    return sig;
  }

  Future<void> _syncReadReceipt() async {
    if (_messages.isEmpty) return;

    final now = DateTime.now();
    if (_lastReadSyncAt != null &&
        now.difference(_lastReadSyncAt!) < _readSyncMinInterval) {
      return;
    }
    _lastReadSyncAt = now;

    final lastId = _messages.last.id;

    try {
      await ConversationApi.markConversationRead(
        conversationId: widget.conversationId,
        peoplePublicId: widget.currentPersonId,
        lastReadMessageId: lastId,
      );
    } catch (_) {
      // silencieux
    }
  }

  Future<void> _loadInitial() async {
    try {
      final msgs = await ConversationApi.fetchMessages(
        widget.conversationId,
        viewerPeopleId: widget.currentPersonId,
      );

      if (!mounted) return;
      setState(() {
        _messages = msgs;
        _initialLoading = false;
      });

      // ✅ scroll first (UI), then sync read (network)
      if (!_didInitialScroll) {
        _didInitialScroll = true;
        _scheduleScrollToBottom(animated: false);
      }

      // Fire and forget: do not block initial scroll
      unawaited(_syncReadReceipt());
      ConversationEvents.bump();
    } catch (e) {
      if (!mounted) return;
      setState(() => _initialLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur chargement messages : $e')),
      );
    }
  }

  Future<void> _reloadMessages({bool scrollIfAtBottom = false}) async {
    if (_reloading) return;
    _reloading = true;

    final bool wasAtBottom = scrollIfAtBottom ? _isAtBottom() : false;

    try {
      final msgs = await ConversationApi.fetchMessages(
        widget.conversationId,
        viewerPeopleId: widget.currentPersonId,
      );
      if (!mounted) return;

      final oldSig = _messagesSignature(_messages);
      final newSig = _messagesSignature(msgs);

      if (oldSig == newSig) return;

      setState(() => _messages = msgs);

      // sync read (throttled)
      unawaited(_syncReadReceipt());

      ConversationEvents.bump();

      final shouldScroll =
          _forceScrollAfterNextReload || (wasAtBottom && !_userScrollingUp);

      if (shouldScroll) {
        _forceScrollAfterNextReload = false;
        _scheduleScrollToBottom(animated: true);
      }
    } catch (_) {
      // silent during polling
    } finally {
      _reloading = false;
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);

    try {
      await ConversationApi.sendMessage(
        conversationId: widget.conversationId,
        senderPeopleId: widget.currentPersonId,
        bodyText: text,
        replyToMessageId: _replyToMessage?.id,
      );

      _controller.clear();
      setState(() => _replyToMessage = null);

      _forceScrollAfterNextReload = true;
      await _reloadMessages(scrollIfAtBottom: true);
      ConversationEvents.bump();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur lors de l’envoi : $e')));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _editMessage(ChatMessage msg) async {
    if (!_isMine(msg)) return;
    if (_isDeleted(msg)) return;

    final editController = TextEditingController(text: msg.bodyText);

    final newText = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Modifier le message'),
          content: TextField(
            controller: editController,
            minLines: 1,
            maxLines: 5,
            autofocus: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Votre message',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                final t = editController.text.trim();
                Navigator.of(ctx).pop(t.isEmpty ? null : t);
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );

    if (newText == null || newText == msg.bodyText) return;

    try {
      await ConversationApi.editMessage(
        messageId: msg.id,
        editorPeopleId: widget.currentPersonId,
        newBodyText: newText,
      );

      await _reloadMessages(scrollIfAtBottom: false);
      ConversationEvents.bump();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la modification : $e')),
      );
    }
  }

  Future<void> _deleteMessage(ChatMessage msg) async {
    if (!_isMine(msg)) return;
    if (_isDeleted(msg)) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Supprimer le message ?'),
          content: const Text(
            'Ce message sera marqué comme supprimé pour cette conversation.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text(
                'Supprimer',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await ConversationApi.deleteMessage(
        messageId: msg.id,
        editorPeopleId: widget.currentPersonId,
      );

      await _reloadMessages(scrollIfAtBottom: false);
      ConversationEvents.bump();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression : $e')),
      );
    }
  }

  void _showMyMessageMenu(ChatMessage msg) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Modifier'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _editMessage(msg);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  'Supprimer',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _deleteMessage(msg);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showOtherMessageMenu(ChatMessage msg) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.reply),
                title: const Text('Répondre'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _startReplyTo(msg);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _startReplyTo(ChatMessage msg) {
    setState(() => _replyToMessage = msg);
    _forceScrollAfterNextReload = true;
    _scheduleScrollToBottom(animated: true);
  }

  bool _userHasReacted(ChatMessage msg, String emoji) {
    return msg.reactions.any(
      (r) => r.peoplePublicId == widget.currentPersonId && r.emoji == emoji,
    );
  }

  Future<void> _showEmojiPicker(ChatMessage msg) async {
    const emojis = ['👍', '❤️', '😂', '😮', '😢', '🙏'];

    final chosen = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: emojis
                  .map(
                    (e) => GestureDetector(
                      onTap: () => Navigator.of(ctx).pop(e),
                      child: Text(e, style: const TextStyle(fontSize: 30)),
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      },
    );

    if (chosen == null) return;

    try {
      final already = _userHasReacted(msg, chosen);
      final deleted = already;

      await ConversationApi.setReaction(
        messageId: msg.id,
        peoplePublicId: widget.currentPersonId,
        emoji: chosen,
        deleted: deleted,
      );

      await _reloadMessages(scrollIfAtBottom: false);
      ConversationEvents.bump();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la réaction : $e')),
      );
    }
  }

  Future<void> _leaveConversation() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Quitter la conversation ?'),
          content: const Text(
            'Êtes-vous sûr(e) de vouloir quitter la conversation et effacer tous vos messages ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Quitter', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await ConversationApi.leaveConversation(
        conversationId: widget.conversationId,
        peoplePublicId: widget.currentPersonId,
        softDeleteOwnMessages: true,
        deleteEmptyConversation: true,
      );

      ConversationEvents.bump();

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur pour quitter : $e')));
    }
  }

  bool _handleScrollNotification(ScrollNotification n) {
    if (n is UserScrollNotification) {
      if (n.direction == ScrollDirection.forward) {
        _userScrollingUp = true;
      } else if (n.direction == ScrollDirection.reverse) {
        if (_isAtBottom()) _userScrollingUp = false;
      } else if (n.direction == ScrollDirection.idle) {
        if (_isAtBottom()) _userScrollingUp = false;
      }
    } else if (n is ScrollEndNotification) {
      if (_isAtBottom()) _userScrollingUp = false;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final body = _initialLoading
        ? const Center(child: CircularProgressIndicator())
        : (_messages.isEmpty
              ? const Center(child: Text('Aucun message pour le moment.'))
              : NotificationListener<ScrollNotification>(
                  onNotification: _handleScrollNotification,
                  child: ListView.builder(
                    controller: _scrollController,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 8,
                    ),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isMine = _isMine(msg);
                      final isDeleted = _isDeleted(msg);

                      final showDateHeader =
                          index == 0 ||
                          !_isSameDay(
                            msg.createdAt,
                            _messages[index - 1].createdAt,
                          );

                      VoidCallback? onLongPress;
                      if (!isDeleted) {
                        onLongPress = isMine
                            ? () => _showMyMessageMenu(msg)
                            : () => _showOtherMessageMenu(msg);
                      }

                      final canReact = !isMine && !isDeleted;

                      return Column(
                        children: [
                          if (showDateHeader)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _formatDayLabel(msg.createdAt),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          GestureDetector(
                            onLongPress: onLongPress,
                            child: _MessageBubble(
                              message: msg,
                              isMine: isMine,
                              timeLabel: _formatTime(
                                (msg.editedAt != null && !_isDeleted(msg))
                                    ? msg.editedAt!
                                    : msg.createdAt,
                              ),
                              showEdited:
                                  msg.editedAt != null && !_isDeleted(msg),
                              onAddReaction: canReact
                                  ? () => _showEmojiPicker(msg)
                                  : null,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ));

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String?>(
          future: _otherPseudoFuture,
          builder: (context, snapshot) {
            final pseudo = snapshot.data;
            final label = (pseudo == null || pseudo.isEmpty)
                ? 'Conversation …'
                : 'Conversation $pseudo';

            return Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            );
          },
        ),
        actions: [
          IconButton(
            tooltip: 'Quitter',
            icon: const Icon(Icons.exit_to_app),
            onPressed: _leaveConversation,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: body),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_replyToMessage != null)
                    _ReplyBanner(
                      message: _replyToMessage!,
                      onCancel: () => setState(() => _replyToMessage = null),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          minLines: 1,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            hintText: 'Message',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(24),
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _sendMessage,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bandeau "Répondre à <pseudo> : <extrait>"
class _ReplyBanner extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback onCancel;

  const _ReplyBanner({required this.message, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final preview = message.bodyText.length > 80
        ? '${message.bodyText.substring(0, 80)}…'
        : message.bodyText;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: Colors.teal.shade400, width: 4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.pseudo,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.teal.shade700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  preview,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade800, fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: onCancel,
          ),
        ],
      ),
    );
  }
}

/// Bulle WhatsApp + reply + réactions + ✅ "vu"
class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMine;
  final String timeLabel;
  final bool showEdited;
  final VoidCallback? onAddReaction;

  const _MessageBubble({
    required this.message,
    required this.isMine,
    required this.timeLabel,
    required this.showEdited,
    this.onAddReaction,
  });

  bool get isDeleted =>
      message.bodyText.trim().toLowerCase() == 'message supprimé';

  @override
  Widget build(BuildContext context) {
    final replyText = (message.replyBodyText ?? '').trim();
    final hasReply = replyText.isNotEmpty && !isDeleted;

    final bubbleColor = isDeleted
        ? Colors.grey.shade300
        : (isMine ? const Color(0xFFDCF8C6) : Colors.white);

    final align = isMine ? Alignment.centerRight : Alignment.centerLeft;

    final radius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(isMine ? 16 : 4),
      bottomRight: Radius.circular(isMine ? 4 : 16),
    );

    final textAlign = isMine
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;

    final Map<String, int> reactionCounts = {};
    for (final r in message.reactions) {
      reactionCounts[r.emoji] = (reactionCounts[r.emoji] ?? 0) + 1;
    }
    final hasReactions = reactionCounts.isNotEmpty;

    final showEmojiIcon = onAddReaction != null && !isDeleted;

    final bool showSeenChecks = isMine && !isDeleted;
    final bool isSeen = message.isSeen == true;
    final checkColor = isSeen ? Colors.blue : Colors.grey.shade600;

    return Align(
      alignment: align,
      child: Column(
        crossAxisAlignment: isMine
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: radius,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.07),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: textAlign,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isMine && !isDeleted) ...[
                        Text(
                          message.pseudo,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.teal.shade700,
                          ),
                        ),
                        const SizedBox(height: 2),
                      ],
                      if (hasReply) ...[
                        Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                            border: Border(
                              left: BorderSide(
                                color: Colors.teal.shade400,
                                width: 3,
                              ),
                            ),
                          ),
                          child: Text(
                            replyText,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                      ],
                      Text(
                        isDeleted ? 'Message supprimé' : message.bodyText,
                        style: TextStyle(
                          fontSize: 15,
                          fontStyle: isDeleted
                              ? FontStyle.italic
                              : FontStyle.normal,
                          color: isDeleted
                              ? Colors.grey.shade700
                              : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: isMine
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          Text(
                            timeLabel,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          if (showEdited && !isDeleted) ...[
                            const SizedBox(width: 4),
                            Text(
                              'modifié',
                              style: TextStyle(
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                          if (showSeenChecks) ...[
                            const SizedBox(width: 6),
                            Icon(Icons.done_all, size: 16, color: checkColor),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (showEmojiIcon)
                Positioned(
                  bottom: -6,
                  right: 0,
                  child: GestureDetector(
                    onTap: onAddReaction,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.emoji_emotions_outlined,
                        size: 20,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (hasReactions)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Wrap(
                spacing: 6,
                children: reactionCounts.entries.map((entry) {
                  final emoji = entry.key;
                  final count = entry.value;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 20)),
                        if (count > 1) ...[
                          const SizedBox(width: 4),
                          Text('$count', style: const TextStyle(fontSize: 12)),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
