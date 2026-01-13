part of map_carto_people;

class _PhotoBytesCache {
  static final Map<String, Uint8List> _cache = {};
  static Uint8List? get(String url) => _cache[url];
  static void put(String url, Uint8List bytes) => _cache[url] = bytes;
}

class _PersonAvatar extends StatelessWidget {
  const _PersonAvatar({
    required this.url,
    required this.onTap,
    required this.headers,
    this.radius = 22,
  });

  final String url;
  final VoidCallback onTap;
  final Map<String, String> headers;
  final double radius;

  Widget _fallback() => CircleAvatar(
    radius: radius,
    backgroundColor: Colors.grey.shade200,
    child: Icon(Icons.person, color: Colors.grey.shade600, size: radius),
  );

  Future<Uint8List?> _loadBytes() async {
    final cached = _PhotoBytesCache.get(url);
    if (cached != null) return cached;

    final resp = await http.get(Uri.parse(url), headers: headers);
    if (resp.statusCode != 200) return null;

    final bytes = resp.bodyBytes;
    _PhotoBytesCache.put(url, bytes);
    return bytes;
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Mobile/desktop natif : OK avec headers
    if (!kIsWeb) {
      return GestureDetector(
        onTap: onTap,
        child: CircleAvatar(
          radius: radius,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: CachedNetworkImageProvider(url, headers: headers),
        ),
      );
    }

    // ✅ Web : on fetch en bytes avec headers, puis Image.memory
    return GestureDetector(
      onTap: onTap,
      child: FutureBuilder<Uint8List?>(
        future: _loadBytes(),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return CircleAvatar(
              radius: radius,
              backgroundColor: Colors.grey.shade200,
              child: const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          final bytes = snap.data;
          if (bytes == null) return _fallback();

          return CircleAvatar(
            radius: radius,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: MemoryImage(bytes),
          );
        },
      ),
    );
  }
}

// ---------- Widgets ----------
class _Bubble extends StatelessWidget {
  const _Bubble({required this.count, required this.size, this.tooltipLabel});
  final int count;
  final double size;
  final String? tooltipLabel;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltipLabel?.trim().isNotEmpty == true
          ? tooltipLabel!
          : '$count',
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.blueAccent.withOpacity(0.85),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          '$count',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

// ---------- Tuile personne ----------
class _PersonTile extends StatefulWidget {
  const _PersonTile({
    required this.person,
    required this.currentPersonId,
    required this.buildPhotoUrl,
    required this.onOpenPhoto,
    super.key,
  });

  final _Person person;
  final int currentPersonId;

  final String Function() buildPhotoUrl;
  final Future<void> Function(String url) onOpenPhoto;

  @override
  State<_PersonTile> createState() => _PersonTileState();
}

String _normalizeGenotype(String raw) {
  final s = raw.trim().toLowerCase();

  // Normalisation simple (inclut variantes possibles)
  if (s.startsWith('dél') || s.startsWith('del')) return 'deletion';
  if (s.startsWith('mut')) return 'mutation';
  if (s == 'upd') return 'upd';
  if (s == 'icd') return 'icd';
  if (s.startsWith('cli')) return 'clinical';
  if (s.startsWith('mos')) return 'mosaic';

  // fallback : renvoyer brut (ou "unknown")
  return 'unknown';
}

String localizedGenotype(BuildContext context, String? raw) {
  final l10n = AppLocalizations.of(context)!;
  if (raw == null || raw.trim().isEmpty) return '';

  switch (_normalizeGenotype(raw)) {
    case 'deletion':
      return l10n.genotypeDeletion;
    case 'mutation':
      return l10n.genotypeMutation;
    case 'upd':
      return l10n.genotypeUpd;
    case 'icd':
      return l10n.genotypeIcd;
    case 'clinical':
      return l10n.genotypeClinical;
    case 'mosaic':
      return l10n.genotypeMosaic;
    default:
      // soit tu affiches raw, soit une string traduite "Inconnu"
      return raw.trim();
  }
}

class _PersonTileState extends State<_PersonTile> {
  final _controller = TextEditingController();
  bool _sending = false;

  bool get _isMe => widget.person.id == widget.currentPersonId;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<int> _createOrGetPrivateConversation({
    required int p1Id,
    required int p2Id,
    String? title,
  }) async {
    final uri = Uri.parse('$_base/conversations/private');

    final payload = <String, dynamic>{'p1_id': p1Id, 'p2_id': p2Id};
    if (title != null && title.trim().isNotEmpty) {
      payload['title'] = title.trim();
    }

    final resp = await http.post(
      uri,
      headers: {
        'X-App-Key': _publicAppKey,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(payload),
    );

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      // (message technique; pas forcément affiché à l'utilisateur)
      throw Exception('conversations/private (${resp.statusCode})');
    }

    final Map<String, dynamic> data = jsonDecode(resp.body);

    final rawId =
        data['id'] ?? data['conversation']?['id'] ?? data['data']?['id'];

    if (rawId is int) return rawId;
    if (rawId is String) return int.parse(rawId);

    throw Exception('conversation_id_not_found');
  }

  Future<void> _sendMessageToConversation({
    required int conversationId,
    required int senderPeopleId,
    required String bodyText,
  }) async {
    final uri = Uri.parse('$_base/conversations/$conversationId/messages');

    final body = <String, dynamic>{
      'sender_people_id': senderPeopleId,
      'body_text': bodyText,
      'reply_to_message_id': null,
      'has_attachments': false,
      'status': 'normal',
    };

    final resp = await http.post(
      uri,
      headers: {
        'X-App-Key': _publicAppKey,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('send_message_failed (${resp.statusCode})');
    }
  }

  Future<void> _send() async {
    if (_isMe) return;

    final msg = _controller.text.trim();
    if (msg.isEmpty || _sending) return;

    setState(() => _sending = true);

    try {
      final meId = widget.currentPersonId;
      final otherId = widget.person.id!;

      final convId = await _createOrGetPrivateConversation(
        p1Id: meId,
        p2Id: otherId,
      );

      await _sendMessageToConversation(
        conversationId: convId,
        senderPeopleId: meId,
        bodyText: msg,
      );

      if (!mounted) return;

      _controller.clear();
      ConversationEvents.bump();

      final nav = Navigator.of(context, rootNavigator: true);
      nav.pop();

      Future.microtask(() {
        nav.push(
          MaterialPageRoute(
            builder: (_) =>
                ChatPage(conversationId: convId, currentPersonId: meId),
          ),
        );
      });
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;

      ScaffoldMessenger.of(
        Navigator.of(context, rootNavigator: true).context,
      ).showSnackBar(
        SnackBar(content: Text(l10n.mapPersonTileSendFailed(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = widget.person;

    final subtitleParts = <String>[];

    final geno = localizedGenotype(context, p.genotype);
    if (geno.isNotEmpty) {
      subtitleParts.add(geno);
    }

    if (p.ageInt != null) {
      subtitleParts.add(l10n.mapPersonTileAge(p.ageInt!));
    }

    final subtitle = subtitleParts.isEmpty
        ? (p.city ?? '')
        : subtitleParts.join(' • ');

    final photoUrl = widget.buildPhotoUrl();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,

          leading: _PersonAvatar(
            url: photoUrl,
            onTap: () => widget.onOpenPhoto(photoUrl),
            headers: {'X-App-Key': _publicAppKey},
            radius: 22,
          ),

          title: Text(
            p.firstName,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(subtitle),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 0, bottom: 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  enabled: !_isMe,
                  decoration: InputDecoration(
                    hintText: _isMe
                        ? l10n.mapPersonTileIsMeHint
                        : l10n.mapPersonTileSendHint,
                    isDense: true,
                    border: const OutlineInputBorder(),
                  ),
                  minLines: 1,
                  maxLines: 3,
                ),
              ),
              const SizedBox(width: 8),
              _sending
                  ? const SizedBox(
                      width: 36,
                      height: 36,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : IconButton(
                      tooltip: _isMe
                          ? l10n.mapPersonTileCannotWriteTooltip
                          : l10n.mapPersonTileSendTooltip,
                      icon: Icon(
                        Ionicons.send,
                        color: _isMe
                            ? Colors.grey
                            : Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: _isMe ? null : _send,
                    ),
            ],
          ),
        ),
      ],
    );
  }
}
