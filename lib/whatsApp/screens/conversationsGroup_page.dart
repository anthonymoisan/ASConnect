// lib/whatsApp/screens/conversationsGroup_page.dart
import 'dart:async';

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../models/conversation_summary.dart';
import '../services/conversation_api.dart';
import '../services/conversation_events.dart';
import 'chat_page.dart';

class ConversationsgroupPage extends StatefulWidget {
  final int? personId;

  const ConversationsgroupPage({super.key, required this.personId});

  @override
  State<ConversationsgroupPage> createState() => _ConversationsgroupPageState();
}

class _ConversationsgroupPageState extends State<ConversationsgroupPage>
    with WidgetsBindingObserver {
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
  void didUpdateWidget(covariant ConversationsgroupPage oldWidget) {
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
      s = (s * 31) ^ c.unreadCount;
      s = (s * 31) ^ (c.lastMessageAt?.millisecondsSinceEpoch ?? 0);
      s = (s * 31) ^ ((c.memberCount ?? 0));

      final lm = c.lastMessage;
      if (lm != null) {
        s = (s * 31) ^ lm.messageId;
        s = (s * 31) ^ (lm.senderPeopleId ?? 0);
        s = (s * 31) ^ ((lm.isSeen == true) ? 1 : 0);
        s = (s * 31) ^ lm.bodyText.hashCode;
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
      final data =
          await ConversationApi.fetchConversationsGroupSummaryForPerson(pid);
      if (!mounted) return;

      final groups = data.where((c) => c.isGroup == true).toList();

      setState(() {
        _items = groups;
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
      final newData =
          await ConversationApi.fetchConversationsGroupSummaryForPerson(pid);
      if (!mounted) return;

      final groups = newData.where((c) => c.isGroup == true).toList();

      final oldSig = _sig(_items);
      final newSig = _sig(groups);

      if (oldSig != newSig) {
        setState(() {
          _items = groups;
          _error = null;
          _initialLoading = false;
        });
      } else {
        if (_error != null) setState(() => _error = null);
      }
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;

      if (!silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.conversationsLoadError(e.toString()))),
        );
      }

      setState(() => _error = e);
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
      useRootNavigator: true,
      builder: (ctx) {
        final l10n2 = AppLocalizations.of(ctx)!;
        return AlertDialog(
          title: Text(l10n2.conversationsLeaveTitle),
          content: Text(l10n2.conversationsLeaveBody),
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

    if (confirm != true) return;

    try {
      await ConversationApi.leaveGroupConversation(
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

  // ---------------------------------------------------------------------------
  // ✅ Création groupe (dialog) — controllers gérés par le dialog
  // ---------------------------------------------------------------------------

  Future<void> _openCreateGroupDialog() async {
    final pid = widget.personId;
    if (pid == null) return;

    final int? createdConversationId = await showDialog<int>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (_) => _CreateGroupDialog(peoplePublicId: pid),
    );

    if (!mounted) return;

    if (createdConversationId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await _openConversation(createdConversationId);
        if (mounted) _reload(silent: true);
      });
    }
  }

  // ---------------------------------------------------------------------------

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

  String _groupTitle(BuildContext context, ConversationSummary conv) {
    final l10n = AppLocalizations.of(context)!;
    final raw = conv.title.trim();
    if (raw.isEmpty) return l10n.tabGroup;
    return raw;
  }

  String _membersLine(ConversationSummary conv) {
    // Note: memberCount is still dynamic, translation already handled by l10n.groupMembersCount
    final mc = conv.memberCount;
    if (mc == null || mc <= 0) return '';
    final l10n = AppLocalizations.of(context)!;
    return l10n.groupMembersCount(mc);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (widget.personId == null) {
      return Center(child: Text(l10n.conversationsReconnectToSee));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tabGroup),
        actions: [
          IconButton(
            tooltip: l10n.groupCreateTooltip,
            icon: const Icon(Icons.add),
            onPressed: _openCreateGroupDialog,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _reload(silent: false),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
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
        final members = _membersLine(conv);

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _groupTitle(context, conv),
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
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (members.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  members,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.orange.shade800, fontSize: 12),
                ),
              ],
              const SizedBox(height: 2),
              _GroupLastLine(conv: conv),
            ],
          ),
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
// Dialog : possède ses controllers -> dispose garanti au bon moment
// ============================================================================

class _CreateGroupDialog extends StatefulWidget {
  final int peoplePublicId;

  const _CreateGroupDialog({required this.peoplePublicId});

  @override
  State<_CreateGroupDialog> createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<_CreateGroupDialog> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _firstMsgCtrl;

  bool _creating = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController();
    _firstMsgCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _firstMsgCtrl.dispose();
    super.dispose();
  }

  Future<void> _onCreate() async {
    final l10n = AppLocalizations.of(context)!;
    final pid = widget.peoplePublicId;

    final title = _titleCtrl.text.trim();
    final firstMsg = _firstMsgCtrl.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.groupTitleRequired)));
      return;
    }

    setState(() => _creating = true);

    try {
      final members = await ConversationApi.fetchPeopleIdsForGroupFilters(
        peoplePublicId: pid,
      );

      if (!members.contains(pid)) members.add(pid);
      if (members.isEmpty) {
        throw Exception(l10n.groupCreateNoMembers);
      }

      final conv = await ConversationApi.createGroupConversation(
        peoplePublicId: pid,
        listIdPeoplesMember: members,
        title: title,
      );

      if (firstMsg.isNotEmpty) {
        await ConversationApi.sendMessage(
          conversationId: conv.id,
          senderPeopleId: pid,
          bodyText: firstMsg,
        );
      }

      if (!mounted) return;

      Navigator.of(context, rootNavigator: true).pop(conv.id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
      setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: !_creating,
      child: AlertDialog(
        title: Text(l10n.groupCreateTitle),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.groupCreateIntro),
              const SizedBox(height: 16),
              TextField(
                controller: _titleCtrl,
                maxLength: 255,
                decoration: InputDecoration(
                  labelText: l10n.groupTitleLabel,
                  border: const OutlineInputBorder(),
                ),
                enabled: !_creating,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _firstMsgCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.groupFirstMessageLabel,
                  border: const OutlineInputBorder(),
                ),
                enabled: !_creating,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _creating
                ? null
                : () => Navigator.of(context, rootNavigator: true).pop(null),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: _creating ? null : _onCreate,
            child: _creating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    l10n.groupCreateButton,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// UI helpers
// ============================================================================

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

class _GroupLastLine extends StatelessWidget {
  final ConversationSummary conv;

  const _GroupLastLine({required this.conv});

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

    final pseudo = (last.pseudo).trim();
    final prefix = pseudo.isEmpty ? '' : '$pseudo : ';
    final text = '$prefix${last.bodyText}';

    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(color: Colors.grey.shade700),
    );
  }
}
