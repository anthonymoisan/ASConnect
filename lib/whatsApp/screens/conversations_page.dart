// lib/whatsApp/screens/conversations_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/conversation_summary.dart';
import '../services/conversation_api.dart';
import '../services/conversation_events.dart';
import 'chat_page.dart';

class ConversationsPage extends StatefulWidget {
  final int? personId;

  const ConversationsPage({super.key, required this.personId});

  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage>
    with WidgetsBindingObserver {
  // ✅ On garde les données en mémoire pour éviter tout “spinner” au refresh
  List<ConversationSummary> _items = [];
  bool _initialLoading = true;
  Object? _error;

  Timer? _pollTimer;
  bool _pollingEnabled = true;
  bool _reloading = false;

  static const Duration _pollInterval = Duration(seconds: 10);

  void _onRefreshTick() => _reload(silent: true);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    ConversationEvents.refreshTick.addListener(_onRefreshTick);

    _loadInitial();
    _startPolling();
  }

  @override
  void dispose() {
    _stopPolling();
    WidgetsBinding.instance.removeObserver(this);

    ConversationEvents.refreshTick.removeListener(_onRefreshTick);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ConversationsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.personId != widget.personId) {
      _items = [];
      _error = null;
      _initialLoading = true;
      _loadInitial();
      _startPolling();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _pollingEnabled = true;
      _startPolling();
      _reload(silent: true);
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
      await _reload(silent: true);
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  // ✅ Petite signature pour éviter setState si pas de changement
  int _sig(List<ConversationSummary> list) {
    int s = list.length;
    for (final c in list) {
      s = (s * 31) ^ c.id;
      s = (s * 31) ^ (c.unreadCount);
      s = (s * 31) ^ (c.lastMessageAt?.millisecondsSinceEpoch ?? 0);

      final lm = c.lastMessage;
      if (lm != null) {
        s = (s * 31) ^ (lm.messageId ?? 0);
        s = (s * 31) ^ (lm.senderPeopleId ?? 0);
        s = (s * 31) ^ ((lm.isSeen == true) ? 1 : 0);
        s = (s * 31) ^ (lm.bodyText.hashCode);
      }
    }
    return s;
  }

  Future<void> _loadInitial() async {
    final pid = widget.personId;
    if (pid == null) {
      if (!mounted) return;
      setState(() {
        _items = [];
        _initialLoading = false;
        _error = null;
      });
      return;
    }

    try {
      final data = await ConversationApi.fetchConversationsSummaryForPerson(
        pid,
      );
      if (!mounted) return;

      setState(() {
        _items = data;
        _initialLoading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _initialLoading = false;
        _error = e;
      });
    }
  }

  // ✅ Reload “silencieux” : pas de spinner / pas de flash
  Future<void> _reload({bool silent = false}) async {
    if (_reloading) return;
    _reloading = true;

    final pid = widget.personId;
    if (pid == null) {
      if (mounted) {
        setState(() {
          _items = [];
          _error = null;
          _initialLoading = false;
        });
      }
      _reloading = false;
      return;
    }

    try {
      final newData = await ConversationApi.fetchConversationsSummaryForPerson(
        pid,
      );
      if (!mounted) return;

      final oldSig = _sig(_items);
      final newSig = _sig(newData);

      if (oldSig != newSig) {
        setState(() {
          _items = newData;
          _error = null;
          _initialLoading = false;
        });
      } else {
        // ✅ même si pas de changement, on enlève une éventuelle erreur passée
        if (_error != null) {
          setState(() => _error = null);
        }
      }
    } catch (e) {
      if (!mounted) return;
      // ✅ En refresh auto : on n’affiche pas une page d’erreur qui remplace tout.
      // On garde la liste existante, et on stocke l’erreur si tu veux diagnostiquer.
      if (!silent) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur de chargement : $e')));
      }
      _error = e;
    } finally {
      _reloading = false;
    }
  }

  Future<void> _openConversation(int conversationId) async {
    final pid = widget.personId;
    if (pid == null) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            ChatPage(conversationId: conversationId, currentPersonId: pid),
      ),
    );

    if (!mounted) return;
    _reload(silent: true);
  }

  Future<void> _confirmLeaveConversation(int conversationId) async {
    final pid = widget.personId;
    if (pid == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quitter la conversation ?'),
        content: const Text(
          'Êtes-vous sûr(e) de vouloir quitter la conversation ?\n'
          'Tous vos messages seront effacés.',
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
      ),
    );

    if (confirm != true) return;

    try {
      await ConversationApi.leaveConversation(
        conversationId: conversationId,
        peoplePublicId: pid,
        softDeleteOwnMessages: true,
        deleteEmptyConversation: true,
      );
      _reload(silent: true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur : $e')));
    }
  }

  String _formatConversationDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(date.year, date.month, date.day);
    final diff = today.difference(messageDay).inDays;

    if (diff == 0) {
      final hh = date.hour.toString().padLeft(2, '0');
      final mm = date.minute.toString().padLeft(2, '0');
      return "$hh:$mm";
    }
    if (diff == 1) return "hier";

    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final yyyy = date.year.toString();
    return "$dd/$mm/$yyyy";
  }

  void _openAvatarFullScreen(int otherPeopleId) {
    final url = personPhotoUrl(otherPeopleId);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Photo',
      barrierColor: Colors.black,
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (ctx, _, __) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: InteractiveViewer(
                    minScale: 1.0,
                    maxScale: 4.0,
                    child: CachedNetworkImage(
                      imageUrl: url,
                      httpHeaders: {'X-App-Key': publicAppKey},
                      fit: BoxFit.contain,
                      placeholder: (_, __) => const SizedBox(
                        width: 36,
                        height: 36,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (_, __, ___) => const Icon(
                        Icons.person,
                        size: 120,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(ctx).pop(),
                    tooltip: 'Fermer',
                  ),
                ),
              ],
            ),
          ),
        );
      },
      transitionBuilder: (ctx, anim, _, child) {
        return FadeTransition(opacity: anim, child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.personId == null) {
      return const Center(
        child: Text('Veuillez vous reconnecter pour voir vos discussions.'),
      );
    }

    final pid = widget.personId!;

    // ✅ Pull-to-refresh sans spinner : RefreshIndicator affiche juste la “barre”
    return RefreshIndicator(
      onRefresh: () => _reload(silent: false),
      child: _buildBody(pid),
    );
  }

  Widget _buildBody(int pid) {
    // ✅ “Chargement initial” : on évite le spinner (tu peux styliser)
    if (_initialLoading && _items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 160),
          Center(
            child: Text('Chargement…', style: TextStyle(color: Colors.black54)),
          ),
        ],
      );
    }

    // ✅ Si vide (après chargement)
    if (_items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 160),
          Center(child: Text('Aucune conversation')),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final conv = _items[index];

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),

          leading: _ConversationAvatarFast(otherPeopleId: conv.otherPeopleId),

          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  conv.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                _formatConversationDate(conv.lastMessageAt),
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),

          subtitle: _LastLine(conv: conv, currentPersonId: pid),

          trailing: conv.unreadCount > 0
              ? _UnreadBubble(count: conv.unreadCount)
              : null,

          onTap: () => _openConversation(conv.id),
          onLongPress: () => _confirmLeaveConversation(conv.id),
        );
      },
    );
  }
}

class _ConversationAvatarFast extends StatelessWidget {
  final int? otherPeopleId;

  const _ConversationAvatarFast({required this.otherPeopleId});

  @override
  Widget build(BuildContext context) {
    if (otherPeopleId == null) {
      return const CircleAvatar(radius: 22, child: Icon(Icons.group));
    }

    final url = personPhotoUrl(otherPeopleId!);

    return GestureDetector(
      onTap: () {
        final st = context.findAncestorStateOfType<_ConversationsPageState>();
        if (st != null) st._openAvatarFullScreen(otherPeopleId!);
      },
      child: CircleAvatar(
        radius: 22,
        backgroundImage: CachedNetworkImageProvider(
          url,
          headers: {'X-App-Key': publicAppKey},
        ),
      ),
    );
  }
}

class _UnreadBubble extends StatelessWidget {
  final int count;

  const _UnreadBubble({required this.count});

  @override
  Widget build(BuildContext context) {
    final label = count > 99 ? '99+' : '$count';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF25D366), // WhatsApp green
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _LastLine extends StatelessWidget {
  final ConversationSummary conv;
  final int currentPersonId;

  const _LastLine({required this.conv, required this.currentPersonId});

  @override
  Widget build(BuildContext context) {
    final last = conv.lastMessage;

    if (last == null) {
      return Text(
        'Aucun message',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.grey.shade600),
      );
    }

    // ✅ isMine = dernier message envoyé par moi
    final isMine =
        (last.senderPeopleId != null && last.senderPeopleId == currentPersonId);

    Widget? statusIcon;
    if (isMine) {
      final seen = (last.isSeen == true);
      statusIcon = Icon(
        seen ? Icons.done_all : Icons.done,
        size: 16,
        color: seen ? Colors.blue : Colors.grey.shade600,
      );
    }

    final text = '${last.pseudo} : ${last.bodyText}';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (statusIcon != null) ...[statusIcon, const SizedBox(width: 6)],
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ),
      ],
    );
  }
}
