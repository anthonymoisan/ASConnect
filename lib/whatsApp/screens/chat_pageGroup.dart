// lib/whatsApp/screens/chat_pageGroup.dart
//
// ✅ Modifs demandées :
// - Titre AppBar = conversationTitle (passé depuis la liste)
// - Messages des autres : avatar miniature à gauche, COLLÉ à la bulle
// - Messages de moi : toujours à droite (sans avatar)
// - Dans la bulle : "~Pseudo" en marron, puis à la ligne le message
// - Réactions / reply / "vu" conservés
// - ✅ Bouton "quitter" :
//    - si je suis admin => confirmer + DELETE group conversation
//    - sinon => confirmer + LEAVE conversation

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../tabular/models/person.dart'; // personPhotoUrl + publicAppKey

import '../models/chat_message.dart';
import '../services/conversation_api.dart';
import '../services/conversation_events.dart';

class ChatPageGroup extends StatefulWidget {
  final int conversationId;
  final int currentPersonId;
  final String conversationTitle;

  const ChatPageGroup({
    super.key,
    required this.conversationId,
    required this.currentPersonId,
    required this.conversationTitle,
  });

  @override
  State<ChatPageGroup> createState() => _ChatPageGroupState();
}

class _ChatPageGroupState extends State<ChatPageGroup>
    with WidgetsBindingObserver {
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

  // ✅ admin check (lazy)
  bool? _iAmAdmin;

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

    // best-effort: resolve admin once
    unawaited(_resolveAdminStatus());
  }

  Future<void> _resolveAdminStatus() async {
    try {
      // 👉 IMPORTANT:
      // Cette méthode est supposée exister chez toi car utilisée dans ConversationsgroupPage
      // (fetchConversationsGroupSummaryForPerson). On réutilise la même pour trouver idAdmin.
      final list =
          await ConversationApi.fetchConversationsGroupSummaryForPerson(
            widget.currentPersonId,
          );
      final conv = list.firstWhere((c) => c.id == widget.conversationId);
      final adminId = conv.idAdmin;
      if (!mounted) return;
      setState(
        () =>
            _iAmAdmin = (adminId != null && adminId == widget.currentPersonId),
      );
    } catch (_) {
      // si on ne peut pas déterminer, on considère "non admin"
      if (!mounted) return;
      setState(() => _iAmAdmin ??= false);
    }
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

  String _formatTime(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return DateFormat.Hm(locale).format(date);
  }

  String _formatDayLabel(BuildContext context, DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toLanguageTag();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    final diff = today.difference(d).inDays;

    if (diff == 0) return l10n.today;
    if (diff == 1) return l10n.yesterday;

    return DateFormat.yMMMd(locale).format(date);
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

  int _hashStr(String s) {
    final bytes = utf8.encode(s);
    int h = 0;
    for (final b in bytes) {
      h = (h * 31) ^ b;
    }
    return h;
  }

  int _messagesSignature(List<ChatMessage> list) {
    int sig = list.length;
    for (final m in list) {
      sig = (sig * 31) ^ m.id;
      sig = (sig * 31) ^ m.senderPeopleId;
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
    } catch (_) {}
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

      if (!_didInitialScroll) {
        _didInitialScroll = true;
        _scheduleScrollToBottom(animated: false);
      }

      unawaited(_syncReadReceipt());
      ConversationEvents.bump();
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;

      setState(() => _initialLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.chatLoadMessagesError(e.toString()))),
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

      unawaited(_syncReadReceipt());
      ConversationEvents.bump();

      final shouldScroll =
          _forceScrollAfterNextReload || (wasAtBottom && !_userScrollingUp);

      if (shouldScroll) {
        _forceScrollAfterNextReload = false;
        _scheduleScrollToBottom(animated: true);
      }
    } catch (_) {
    } finally {
      _reloading = false;
    }
  }

  Future<void> _sendMessage() async {
    final l10n = AppLocalizations.of(context)!;

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
      ).showSnackBar(SnackBar(content: Text(l10n.chatSendError(e.toString()))));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  // ---------------------------------------------------------------------------
  // ✅ Quitter / Supprimer selon admin
  // ---------------------------------------------------------------------------

  Future<void> _confirmDeleteGroup() async {
    final l10n = AppLocalizations.of(context)!;

    final ok = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) {
        final l10n2 = AppLocalizations.of(ctx)!;
        return AlertDialog(
          title: Text(l10n2.groupDeleteTitle),
          content: Text(l10n2.groupDeleteBody),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(ctx, rootNavigator: true).pop(false),
              child: Text(l10n2.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx, rootNavigator: true).pop(true),
              child: Text(
                l10n2.groupDeleteConfirm,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (ok != true) return;

    try {
      // 👉 IMPORTANT: méthode supposée exister (déjà utilisée dans ConversationsgroupPage)
      await ConversationApi.deleteGroupConversation(
        conversationId: widget.conversationId,
        peoplePublicId: widget.currentPersonId,
      );

      ConversationEvents.bump();
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.genericError(e.toString()))));
    }
  }

  Future<void> _confirmLeaveGroup() async {
    final l10n = AppLocalizations.of(context)!;

    final ok = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) {
        final l10n2 = AppLocalizations.of(ctx)!;
        return AlertDialog(
          title: Text(l10n2.conversationsLeaveTitle),
          content: Text(l10n2.chatLeaveConversationBody),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(ctx, rootNavigator: true).pop(false),
              child: Text(l10n2.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx, rootNavigator: true).pop(true),
              child: Text(
                l10n2.conversationsLeaveConfirm,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (ok != true) return;

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.chatLeaveError(e.toString()))),
      );
    }
  }

  Future<void> _onQuitOrDeletePressed() async {
    // si status inconnu -> on tente de le résoudre rapidement
    if (_iAmAdmin == null) {
      await _resolveAdminStatus();
    }

    final isAdmin = _iAmAdmin == true;

    if (isAdmin) {
      await _confirmDeleteGroup();
    } else {
      await _confirmLeaveGroup();
    }
  }

  // ---------------------------------------------------------------------------

  void _showMyMessageMenu(ChatMessage msg) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        final l10n2 = AppLocalizations.of(ctx)!;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: Text(l10n2.edit),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _editMessage(msg);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: Text(
                  l10n2.delete,
                  style: const TextStyle(color: Colors.red),
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

  Future<void> _editMessage(ChatMessage msg) async {
    if (!_isMine(msg)) return;
    if (_isDeleted(msg)) return;

    final l10n = AppLocalizations.of(context)!;
    final editController = TextEditingController(text: msg.bodyText);

    final newText = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final l10n2 = AppLocalizations.of(ctx)!;
        return AlertDialog(
          title: Text(l10n2.chatEditMessageTitle),
          content: TextField(
            controller: editController,
            minLines: 1,
            maxLines: 5,
            autofocus: true,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: l10n2.chatYourMessageHint,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: Text(l10n2.cancel),
            ),
            TextButton(
              onPressed: () {
                final t = editController.text.trim();
                Navigator.of(ctx).pop(t.isEmpty ? null : t);
              },
              child: Text(l10n2.save),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.chatEditError(e.toString()))));
    }
  }

  Future<void> _deleteMessage(ChatMessage msg) async {
    if (!_isMine(msg)) return;
    if (_isDeleted(msg)) return;

    final l10n = AppLocalizations.of(context)!;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final l10n2 = AppLocalizations.of(ctx)!;
        return AlertDialog(
          title: Text(l10n2.chatDeleteMessageTitle),
          content: Text(l10n2.chatDeleteMessageBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n2.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(
                l10n2.delete,
                style: const TextStyle(color: Colors.red),
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
        SnackBar(content: Text(l10n.chatDeleteError(e.toString()))),
      );
    }
  }

  void _showOtherMessageMenu(ChatMessage msg) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        final l10n2 = AppLocalizations.of(ctx)!;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.reply),
                title: Text(l10n2.reply),
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
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.chatReactError(e.toString()))),
      );
    }
  }

  bool _userHasReacted(ChatMessage msg, String emoji) {
    return msg.reactions.any(
      (r) => r.peoplePublicId == widget.currentPersonId && r.emoji == emoji,
    );
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
    final l10n = AppLocalizations.of(context)!;

    final body = _initialLoading
        ? const Center(child: CircularProgressIndicator())
        : (_messages.isEmpty
              ? Center(child: Text(l10n.chatNoMessagesYet))
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

                      final bubble = GestureDetector(
                        onLongPress: onLongPress,
                        child: _MessageBubble(
                          message: msg,
                          isMine: isMine,
                          timeLabel: _formatTime(
                            context,
                            (msg.editedAt != null && !_isDeleted(msg))
                                ? msg.editedAt!
                                : msg.createdAt,
                          ),
                          showEdited: msg.editedAt != null && !_isDeleted(msg),
                          onAddReaction: canReact
                              ? () => _showEmojiPicker(msg)
                              : null,
                        ),
                      );

                      final line = isMine
                          ? bubble
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: PeopleMiniAvatar(
                                    peopleId: msg.senderPeopleId,
                                    radius: 14,
                                  ),
                                ),
                                const SizedBox(width: 0),
                                Expanded(child: bubble),
                                const SizedBox(width: 36),
                              ],
                            );

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
                                    _formatDayLabel(context, msg.createdAt),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          line,
                        ],
                      );
                    },
                  ),
                ));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          (widget.conversationTitle.trim().isEmpty)
              ? AppLocalizations.of(context)!.tabGroup
              : widget.conversationTitle.trim(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            tooltip: (_iAmAdmin == true)
                ? (l10n.groupDeleteConfirm)
                : (l10n.conversationsLeaveConfirm),
            icon: Icon(
              (_iAmAdmin == true) ? Icons.delete_outline : Icons.exit_to_app,
              color: (_iAmAdmin == true) ? Colors.red.shade400 : null,
            ),
            onPressed: _onQuitOrDeletePressed,
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
                          decoration: InputDecoration(
                            hintText: l10n.message,
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(24),
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: l10n.send,
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
    final l10n = AppLocalizations.of(context)!;

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
                      if (!isDeleted) ...[
                        Text(
                          '~${message.pseudo}'.trim(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.brown.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
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
                        isDeleted ? l10n.deletedMessage : message.bodyText,
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
                              l10n.edited,
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

// ✅ Avatar mini (cache mémoire + header X-App-Key)
class PeopleMiniAvatar extends StatefulWidget {
  const PeopleMiniAvatar({super.key, required this.peopleId, this.radius = 14});

  final int peopleId;
  final double radius;

  @override
  State<PeopleMiniAvatar> createState() => _PeopleMiniAvatarState();
}

class _PeopleMiniAvatarState extends State<PeopleMiniAvatar> {
  static final Map<int, Uint8List> _memCache = {};
  Future<Uint8List?>? _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void didUpdateWidget(covariant PeopleMiniAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.peopleId != widget.peopleId) {
      _future = _load();
    }
  }

  Future<Uint8List?> _load() async {
    final id = widget.peopleId;

    final cached = _memCache[id];
    if (cached != null) return cached;

    final url = personPhotoUrl(id);
    final resp = await http.get(
      Uri.parse(url),
      headers: {'X-App-Key': publicAppKey},
    );

    if (resp.statusCode == 200 && resp.bodyBytes.isNotEmpty) {
      _memCache[id] = resp.bodyBytes;
      return resp.bodyBytes;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.radius;

    Widget fallback() => CircleAvatar(
      radius: r,
      backgroundColor: Colors.grey.shade200,
      child: Icon(Icons.person, size: r * 1.2, color: Colors.black54),
    );

    return FutureBuilder<Uint8List?>(
      future: _future,
      builder: (ctx, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return CircleAvatar(
            radius: r,
            backgroundColor: Colors.grey.shade200,
            child: const SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final bytes = snap.data;
        if (bytes == null) return fallback();

        return CircleAvatar(
          radius: r,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: MemoryImage(bytes),
        );
      },
    );
  }
}
