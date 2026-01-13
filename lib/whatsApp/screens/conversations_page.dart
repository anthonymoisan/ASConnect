import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../l10n/app_localizations.dart';
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
  List<ConversationSummary> _items = [];
  bool _initialLoading = true;
  Object? _error;

  Timer? _pollTimer;
  bool _pollingEnabled = true;
  bool _reloading = false;

  final Set<int> _loggedConvIds = {};

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

  int _sig(List<ConversationSummary> list) {
    int s = list.length;
    for (final c in list) {
      s = (s * 31) ^ c.id;
      s = (s * 31) ^ (c.unreadCount);
      s = (s * 31) ^ (c.lastMessageAt?.millisecondsSinceEpoch ?? 0);

      s = (s * 31) ^ ((c.otherIsConnected == true) ? 1 : 0);

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
        if (_error != null) {
          setState(() => _error = null);
        }
      }
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;

      if (!silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.conversationsLoadError(e.toString()))),
        );
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

    final l10n = AppLocalizations.of(context)!;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final l10n2 = AppLocalizations.of(ctx)!;
        return AlertDialog(
          title: Text(l10n2.conversationsLeaveTitle),
          content: Text(l10n2.conversationsLeaveBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n2.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(
                l10n2.conversationsLeaveConfirm,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
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
      ).showSnackBar(SnackBar(content: Text(l10n.genericError(e.toString()))));
    }
  }

  String _formatConversationDate(DateTime? date) {
    if (date == null) return '';

    final l10n = AppLocalizations.of(context)!;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(date.year, date.month, date.day);
    final diff = today.difference(messageDay).inDays;

    if (diff == 0) {
      final hh = date.hour.toString().padLeft(2, '0');
      final mm = date.minute.toString().padLeft(2, '0');
      return "$hh:$mm";
    }
    if (diff == 1) return l10n.yesterday;

    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final yyyy = date.year.toString();
    return "$dd/$mm/$yyyy";
  }

  String _conversationTitle(BuildContext context, ConversationSummary conv) {
    final l10n = AppLocalizations.of(context)!;

    final raw = conv.title.trim();
    if (raw.isEmpty) return l10n.chatWithName('—');

    // ✅ enlève le préfixe FR si déjà présent (API renvoie "Chat avec Pseudo")
    final pseudo = raw
        .replaceFirst(RegExp(r'^Chat\s+avec\s+', caseSensitive: false), '')
        .trim();

    // ✅ maintenant on applique la version multi-langue UNE seule fois
    return l10n.chatWithName(pseudo.isEmpty ? '—' : pseudo);
  }

  void _openAvatarFullScreen(int otherPeopleId) {
    final l10n = AppLocalizations.of(context)!;
    final url = personPhotoUrl(otherPeopleId);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: l10n.photo,
      barrierColor: Colors.black,
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (ctx, _, __) {
        final l10n2 = AppLocalizations.of(ctx)!;
        return Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: InteractiveViewer(
                    minScale: 1.0,
                    maxScale: 4.0,
                    child: Image.network(
                      url,
                      headers: {'X-App-Key': publicAppKey},
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.person,
                        size: 120,
                        color: Colors.white54,
                      ),
                      loadingBuilder: (ctx, child, prog) {
                        if (prog == null) return child;
                        return const SizedBox(
                          width: 36,
                          height: 36,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(ctx).pop(),
                    tooltip: l10n2.close,
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
    final l10n = AppLocalizations.of(context)!;

    if (widget.personId == null) {
      return Center(child: Text(l10n.conversationsReconnectToSee));
    }

    final pid = widget.personId!;

    return RefreshIndicator(
      onRefresh: () => _reload(silent: false),
      child: _buildBody(pid),
    );
  }

  Widget _buildBody(int pid) {
    final l10n = AppLocalizations.of(context)!;

    if (_initialLoading && _items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 160),
          Center(
            child: Text(
              l10n.loading,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      );
    }

    if (_items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 160),
          Center(child: Text(l10n.conversationsEmpty)),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final conv = _items[index];

        if (_loggedConvIds.add(conv.id)) {
          debugPrint(
            "[CONV] id=${conv.id} otherPeopleId=${conv.otherPeopleId} "
            "otherIsConnected=${conv.otherIsConnected} (${conv.otherIsConnected.runtimeType})",
          );
        }

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: _PeoplePhotoAvatarWithStatus(
            peopleId: conv.otherPeopleId,
            radius: 22,
            isOnline: conv.otherIsConnected, // à adapter selon ton modèle
            onTap: () {
              final id = conv.otherPeopleId;
              if (id != null) _openAvatarFullScreen(id);
            },
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _conversationTitle(context, conv),
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

// ============================================================================
// ✅ Avatar robuste : fetch bytes avec header X-App-Key => Image.memory
// ============================================================================

class _PeoplePhotoAvatar extends StatefulWidget {
  const _PeoplePhotoAvatar({
    required this.peopleId,
    required this.radius,
    this.onTap,
  });

  final int? peopleId;
  final double radius;
  final VoidCallback? onTap;

  @override
  State<_PeoplePhotoAvatar> createState() => _PeoplePhotoAvatarState();
}

class _PeoplePhotoAvatarState extends State<_PeoplePhotoAvatar> {
  static final Map<int, Uint8List> _memCache = {};
  Future<Uint8List?>? _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void didUpdateWidget(covariant _PeoplePhotoAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.peopleId != widget.peopleId) {
      _future = _load();
    }
  }

  Future<Uint8List?> _load() async {
    final id = widget.peopleId;
    if (id == null) return null;

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

    Widget avatarFallback({Widget? child}) => CircleAvatar(
      radius: r,
      backgroundColor: Colors.grey.shade200,
      child: child ?? const Icon(Icons.person, color: Colors.black54),
    );

    final id = widget.peopleId;
    if (id == null) return avatarFallback(child: const Icon(Icons.group));

    return GestureDetector(
      onTap: widget.onTap,
      child: FutureBuilder<Uint8List?>(
        future: _future,
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return avatarFallback(
              child: const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          final bytes = snap.data;
          if (bytes == null) {
            return avatarFallback();
          }

          return CircleAvatar(
            radius: r,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: MemoryImage(bytes),
          );
        },
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
        color: const Color(0xFF25D366),
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
    final l10n = AppLocalizations.of(context)!;

    final last = conv.lastMessage;

    if (last == null) {
      return Text(
        l10n.conversationsNoMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.grey.shade600),
      );
    }

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

class _OnlineDot extends StatelessWidget {
  const _OnlineDot({required this.isOnline, this.size = 10});

  final bool isOnline;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isOnline ? Colors.green : Colors.red,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({
    required this.isOnline,
    required this.tooltipOnline,
    required this.tooltipOffline,
    this.size = 12,
  });

  final bool isOnline;
  final String tooltipOnline;
  final String tooltipOffline;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: isOnline ? tooltipOnline : tooltipOffline,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isOnline ? Colors.green : Colors.red,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
      ),
    );
  }
}

class _PeoplePhotoAvatarWithStatus extends StatelessWidget {
  const _PeoplePhotoAvatarWithStatus({
    required this.peopleId,
    required this.radius,
    required this.isOnline,
    this.onTap,
  });

  final int? peopleId;
  final double radius;
  final bool? isOnline; // null => pas d’info => pas de dot
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // ✅ Reserve de la place dans le leading du ListTile
    final box = radius * 2;

    final dotSize = (radius * 0.55).clamp(10.0, 14.0).toDouble();
    final dotPadding = (radius * 0.12).clamp(1.0, 4.0).toDouble();

    final l10n = AppLocalizations.of(context)!;
    final tooltipOnline = l10n.statusOnline;
    final tooltipOffline = l10n.statusOffline;

    return SizedBox(
      width: box,
      height: box,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.center,
            child: _PeoplePhotoAvatar(
              peopleId: peopleId,
              radius: radius,
              onTap: onTap,
            ),
          ),

          if (isOnline != null)
            Positioned(
              // ✅ pas de valeurs négatives => visible même si le parent clippe
              right: dotPadding,
              top: dotPadding,
              child: _StatusDot(
                isOnline: isOnline!,
                size: dotSize,
                tooltipOnline: tooltipOnline,
                tooltipOffline: tooltipOffline,
              ),
            ),
        ],
      ),
    );
  }
}
