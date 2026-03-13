// lib/whatsApp/screens/conversationsGroup_page.dart

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../../l10n/app_localizations.dart';
import '../../session/app_session.dart';
import '../../tabular/models/person.dart';
import '../../tabular/services/tabular_api.dart';

import '../models/conversation_summary.dart';
import '../models/translation_result.dart';
import '../services/conversation_api.dart';
import '../services/conversation_events.dart';
import 'audience_filters.dart';
import 'chat_pageGroup.dart';
import 'widget_avatar_viewer.dart';

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

  final Map<int, TranslationResult?> _translatedTitlesByConversationId = {};
  final Set<int> _translatingTitleIds = <int>{};

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
      _translatedTitlesByConversationId.clear();
      _translatingTitleIds.clear();
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
      s = (s * 31) ^ (c.memberCount ?? 0);

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

  Future<void> _openConversation(ConversationSummary conv) async {
    final pid = widget.personId;
    if (pid == null) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatPageGroup(
          conversationId: conv.id,
          currentPersonId: pid,
          conversationTitle: conv.title,
        ),
      ),
    );

    if (!mounted) return;
    _reload(silent: true);
  }

  bool _amIAdmin(ConversationSummary conv) {
    final pid = widget.personId;
    final adminId = conv.idAdmin;
    if (pid == null || adminId == null) return false;
    return pid == adminId;
  }

  Future<void> _confirmDeleteGroupConversation(ConversationSummary conv) async {
    final pid = widget.personId;
    if (pid == null) return;

    final confirm = await showDialog<bool>(
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

    if (confirm != true) return;

    try {
      await ConversationApi.deleteGroupConversation(
        conversationId: conv.id,
        peoplePublicId: pid,
      );
      if (!mounted) return;
      _reload(silent: true);
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.genericError(e.toString()))));
    }
  }

  Future<void> _confirmLeaveGroupConversation(ConversationSummary conv) async {
    final pid = widget.personId;
    if (pid == null) return;

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
        conversationId: conv.id,
        peoplePublicId: pid,
        softDeleteOwnMessages: true,
        deleteEmptyConversation: true,
      );
      if (!mounted) return;
      _reload(silent: true);
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.genericError(e.toString()))));
    }
  }

  Future<void> _showConversationMenu(ConversationSummary conv) async {
    final isAdmin = _amIAdmin(conv);
    final l10n = AppLocalizations.of(context)!;

    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(
                  isAdmin ? Icons.delete_outline : Icons.exit_to_app,
                  color: isAdmin ? Colors.red : null,
                ),
                title: Text(
                  isAdmin
                      ? l10n.groupDeleteConfirm
                      : l10n.conversationsLeaveConfirm,
                  style: TextStyle(color: isAdmin ? Colors.red : null),
                ),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  if (isAdmin) {
                    await _confirmDeleteGroupConversation(conv);
                  } else {
                    await _confirmLeaveGroupConversation(conv);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleLongPress(ConversationSummary conv) async {
    if (_amIAdmin(conv)) {
      await _confirmDeleteGroupConversation(conv);
    } else {
      await _confirmLeaveGroupConversation(conv);
    }
  }

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

        final pid2 = widget.personId;
        if (pid2 == null) return;

        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatPageGroup(
              conversationId: createdConversationId,
              currentPersonId: pid2,
              conversationTitle: '',
            ),
          ),
        );

        if (mounted) _reload(silent: true);
      });
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

  String _groupTitle(BuildContext context, ConversationSummary conv) {
    final l10n = AppLocalizations.of(context)!;
    final raw = conv.title.trim();
    if (raw.isEmpty) return l10n.tabGroup;
    return raw;
  }

  String _membersInline(ConversationSummary conv) {
    final mc = conv.memberCount;
    if (mc == null || mc <= 0) return '';
    final l10n = AppLocalizations.of(context)!;
    return l10n.groupMembersCount(mc);
  }

  String _loginLangCode(BuildContext context) {
    return (AppSession.loginLangCode ??
            Localizations.localeOf(context).languageCode)
        .trim()
        .toLowerCase();
  }

  bool _canTranslateGroupTitle(ConversationSummary conv) {
    final raw = conv.title.trim();
    if (raw.isEmpty) return false;

    final loginLang = _loginLangCode(context);
    if (loginLang.isEmpty) return false;

    return true;
  }

  Future<void> _translateGroupTitleOnDemand(ConversationSummary conv) async {
    final raw = conv.title.trim();
    if (raw.isEmpty) return;
    if (!_canTranslateGroupTitle(conv)) return;
    if (_translatingTitleIds.contains(conv.id)) return;

    final loginLang = _loginLangCode(context);

    setState(() {
      _translatingTitleIds.add(conv.id);
    });

    try {
      final result = await ConversationApi.detectAndTranslateText(
        sentence: raw,
        targetLang: loginLang,
      );

      if (!mounted) return;

      final translated = result.translatedText.trim();
      final detected = result.detectedSourceLang.trim().toLowerCase();

      setState(() {
        if (translated.isEmpty ||
            translated == raw ||
            (detected.isNotEmpty && detected == loginLang)) {
          _translatedTitlesByConversationId[conv.id] = null;
        } else {
          _translatedTitlesByConversationId[conv.id] = result;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _translatedTitlesByConversationId[conv.id] = null;
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _translatingTitleIds.remove(conv.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (widget.personId == null) {
      return Center(child: Text(l10n.conversationsReconnectToSee));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: const Color(0xFFF4F7FB),
        surfaceTintColor: Colors.transparent,
        title: const SizedBox.shrink(),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              tooltip: l10n.groupCreateTooltip,
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, size: 20),
              ),
              onPressed: _openCreateGroupDialog,
            ),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          const SizedBox(height: 140),
          Center(child: Text(l10n.loadingGroup)),
        ],
      );
    }

    if (_items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          const SizedBox(height: 140),
          Center(child: Text(l10n.conversationsEmpty)),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final conv = _items[index];
        final last = conv.lastMessage;

        final pseudo = (last?.pseudo ?? '').trim();
        final prefix = pseudo.isEmpty ? '' : '$pseudo : ';
        final lastText = last == null
            ? l10n.conversationsNoMessage
            : '$prefix${last.bodyText}';

        final adminId = conv.idAdmin;

        final rawTitle = _groupTitle(context, conv);
        final membersInline = _membersInline(conv);

        final canTranslateTitle = _canTranslateGroupTitle(conv);
        final translatedTitle = _translatedTitlesByConversationId[conv.id]
            ?.translatedText
            .trim();
        final isTranslatingTitle = _translatingTitleIds.contains(conv.id);

        final showTranslatedTitle =
            translatedTitle != null &&
            translatedTitle.isNotEmpty &&
            translatedTitle != rawTitle.trim();

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Material(
            color: Colors.white,
            elevation: 0,
            borderRadius: BorderRadius.circular(22),
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () => _openConversation(conv),
              onLongPress: () => _handleLongPress(conv),
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.045),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PeoplePhotoAvatar(
                        peopleId: adminId,
                        radius: 29,
                        onTap: adminId == null
                            ? null
                            : () =>
                                  AvatarViewer.open(context, peopleId: adminId),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              rawTitle,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF1D4ED8),
                                                height: 1.15,
                                              ),
                                            ),
                                          ),
                                          if (canTranslateTitle) ...[
                                            const SizedBox(width: 6),
                                            GestureDetector(
                                              onTap: () =>
                                                  _translateGroupTitleOnDemand(
                                                    conv,
                                                  ),
                                              child: AnimatedContainer(
                                                duration: const Duration(
                                                  milliseconds: 180,
                                                ),
                                                padding: const EdgeInsets.all(
                                                  6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFFEAF2FF,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Icon(
                                                  Icons.translate,
                                                  size: 16,
                                                  color: isTranslatingTitle
                                                      ? Colors.blueGrey
                                                      : const Color(0xFF1D4ED8),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      if (isTranslatingTitle) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          '…',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontStyle: FontStyle.italic,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                      if (!isTranslatingTitle &&
                                          showTranslatedTitle) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          translatedTitle,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontStyle: FontStyle.italic,
                                            color: Colors.grey.shade700,
                                            height: 1.2,
                                          ),
                                        ),
                                      ],
                                      if (membersInline.isNotEmpty) ...[
                                        const SizedBox(height: 7),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.group_outlined,
                                              size: 14,
                                              color: Colors.grey.shade600,
                                            ),
                                            const SizedBox(width: 5),
                                            Expanded(
                                              child: Text(
                                                membersInline,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: Colors.grey.shade700,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                _RightMetaColumn(
                                  dateText: _formatConversationDate(
                                    conv.lastMessageAt,
                                  ),
                                  unreadCount: conv.unreadCount,
                                  onMenuTap: () => _showConversationMenu(conv),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.message_outlined,
                                    size: 15,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 7),
                                  Expanded(
                                    child: Text(
                                      lastText,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.grey.shade800,
                                        fontSize: 13,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RightMetaColumn extends StatelessWidget {
  final String dateText;
  final int unreadCount;
  final VoidCallback onMenuTap;

  const _RightMetaColumn({
    required this.dateText,
    required this.unreadCount,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          dateText,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (unreadCount > 0) ...[
              _UnreadBubble(count: unreadCount),
              const SizedBox(width: 6),
            ],
            GestureDetector(
              onTap: onMenuTap,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.more_vert,
                  size: 17,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

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

  List<Person>? _allPeople;
  AudienceFilters<Person>? _audience;
  Map<String, String> _countriesByCode = const {};
  Map<String, String> _languagesByCode = const {};

  int _audienceCount = 0;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController();
    _firstMsgCtrl = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadAudienceDataset();
    });
  }

  Future<({double lat, double lng})?> _resolveMyLocationForAudience(
    BuildContext ctx,
  ) async {
    try {
      try {
        final enabled = await Geolocator.isLocationServiceEnabled();
        if (!enabled) return null;
      } catch (_) {}

      try {
        var perm = await Geolocator.checkPermission();
        if (perm == LocationPermission.denied) {
          perm = await Geolocator.requestPermission();
        }
        if (perm == LocationPermission.denied ||
            perm == LocationPermission.deniedForever) {
          return null;
        }
      } catch (_) {}

      try {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null) return (lat: last.latitude, lng: last.longitude);
      } catch (_) {}

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.lowest,
        timeLimit: const Duration(seconds: 6),
      );

      return (lat: pos.latitude, lng: pos.longitude);
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadAudienceDataset() async {
    try {
      final listPerson = await TabularApi.fetchPeopleMapRepresentation();
      final people = listPerson.items;

      Map<String, String> cMap = const {};
      try {
        final locale = Localizations.localeOf(context).languageCode;
        cMap = await TabularApi.fetchCountriesTranslated(locale: locale);
      } catch (_) {}

      Map<String, String> lMap = const {};
      try {
        final locale = Localizations.localeOf(context).languageCode.trim();
        final res = await TabularApi.fetchPeopleLanguagesTranslated(
          locale: locale.isEmpty ? 'fr' : locale,
        );

        final tmp = <String, String>{};
        for (final item in res.langues) {
          final code = (item.code).trim().toLowerCase();
          final name = (item.name).trim();
          if (code.isNotEmpty && name.isNotEmpty) {
            tmp[code] = name;
          }
        }
        lMap = tmp;
      } catch (_) {}

      if (!mounted) return;

      final initial = AudienceFilters.defaultAll<Person>(
        people,
        countryOf: (p) => p.countryCode,
        ageOf: (p) => p.age,
        languageOf: (p) => p.lang,
      );

      setState(() {
        _allPeople = people;
        _countriesByCode = cMap;
        _languagesByCode = lMap;
        _audience = initial;
        _audienceCount = people.length;
      });
    } catch (e) {
      debugPrint('loadAudienceDataset error: $e');
      if (!mounted) return;
      setState(() {
        _allPeople = null;
        _audience = null;
        _audienceCount = 0;
        _countriesByCode = const {};
        _languagesByCode = const {};
      });
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _firstMsgCtrl.dispose();
    super.dispose();
  }

  int _countMatchingPeople(AudienceFilters<Person> f, List<Person> all) {
    final ageDomain = AudienceFilters.ageDomain(all, (p) => p.age);
    final countryOpts = AudienceFilters.countryOptions(
      all,
      (p) => p.countryCode,
    );
    final langOpts = AudienceFilters.languageOptions(all, (p) => p.lang);

    int count = 0;
    for (final p in all) {
      if (f.matchesPerson(
        p,
        countryOf: (pp) => pp.countryCode,
        ageOf: (pp) => pp.age,
        genotypeOf: (pp) => pp.genotype,
        languageOf: (pp) => pp.lang,
        latOf: (pp) => pp.latitude,
        lngOf: (pp) => pp.longitude,
        datasetAgeDomain: ageDomain,
        datasetCountryOptions: countryOpts,
        datasetLanguageOptions: langOpts,
      )) {
        count++;
      }
    }
    return count;
  }

  Future<void> _openAudienceFilters() async {
    final all = _allPeople;
    final current = _audience;
    if (all == null || current == null) return;

    final updated = await AudienceFiltersSheet.open<Person>(
      context: context,
      allPeople: all,
      initial: current,
      countryOf: (p) => p.countryCode,
      ageOf: (p) => p.age,
      genotypeOf: (p) => p.genotype,
      languageOf: (p) => p.lang,
      latOf: (p) => p.latitude,
      lngOf: (p) => p.longitude,
      countriesByCode: _countriesByCode,
      languagesByCode: _languagesByCode,
      resolveMyLocation: () => _resolveMyLocationForAudience(context),
    );

    if (!mounted) return;
    if (updated != null) {
      final c = _countMatchingPeople(updated, all);
      setState(() {
        _audience = updated;
        _audienceCount = c;
      });
    }
  }

  List<int> _buildAudienceIdsOrFallbackAll({required int pid}) {
    final all = _allPeople;
    final f = _audience;

    if (all == null || f == null) return <int>[pid];

    final ageDomain = AudienceFilters.ageDomain(all, (p) => p.age);
    final countryOpts = AudienceFilters.countryOptions(
      all,
      (p) => p.countryCode,
    );
    final langOpts = AudienceFilters.languageOptions(all, (p) => p.lang);

    final ids = <int>[];
    for (final p in all) {
      final ok = f.matchesPerson(
        p,
        countryOf: (pp) => pp.countryCode,
        ageOf: (pp) => pp.age,
        genotypeOf: (pp) => pp.genotype,
        languageOf: (pp) => pp.lang,
        latOf: (pp) => pp.latitude,
        lngOf: (pp) => pp.longitude,
        datasetAgeDomain: ageDomain,
        datasetCountryOptions: countryOpts,
        datasetLanguageOptions: langOpts,
      );
      if (ok) ids.add(p.id);
    }

    if (!ids.contains(pid)) ids.add(pid);
    return ids;
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
      final members = _buildAudienceIdsOrFallbackAll(pid: pid);
      if (members.isEmpty) throw Exception(l10n.groupCreateNoMembers);

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

    final buttonEnabled = _allPeople != null && _audience != null;
    final datasetLoaded = _allPeople != null;
    final countLabel = datasetLoaded
        ? l10n.groupMembersCount(_audienceCount)
        : '…';

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
              Row(
                children: [
                  const Icon(Icons.tune, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextButton(
                      onPressed: (_creating || !buttonEnabled)
                          ? null
                          : _openAudienceFilters,
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: Row(
                        children: [
                          Text(
                            l10n.audience,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const Spacer(),
                          Text(
                            countLabel,
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.chevron_right, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
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

class _UnreadBubble extends StatelessWidget {
  final int count;

  const _UnreadBubble({required this.count});

  @override
  Widget build(BuildContext context) {
    final label = count > 99 ? '99+' : '$count';

    return Container(
      constraints: const BoxConstraints(minWidth: 24),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF25D366),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 11.5,
        ),
      ),
    );
  }
}

class PeoplePhotoAvatar extends StatefulWidget {
  const PeoplePhotoAvatar({
    super.key,
    required this.peopleId,
    required this.radius,
    this.onTap,
  });

  final int? peopleId;
  final double radius;
  final VoidCallback? onTap;

  @override
  State<PeoplePhotoAvatar> createState() => _PeoplePhotoAvatarState();
}

class _PeoplePhotoAvatarState extends State<PeoplePhotoAvatar> {
  static final Map<int, Uint8List> _memCache = {};
  Future<Uint8List?>? _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void didUpdateWidget(covariant PeoplePhotoAvatar oldWidget) {
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

    Widget fallback({Widget? child}) => CircleAvatar(
      radius: r,
      backgroundColor: Colors.grey.shade200,
      child: child ?? Icon(Icons.person, color: Colors.black54, size: r * 1.2),
    );

    final id = widget.peopleId;
    if (id == null) return fallback(child: const Icon(Icons.person));

    return GestureDetector(
      onTap: widget.onTap,
      child: FutureBuilder<Uint8List?>(
        future: _future,
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return fallback(
              child: const SizedBox(
                width: 14,
                height: 14,
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
      ),
    );
  }
}
