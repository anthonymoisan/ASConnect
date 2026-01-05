import '../whatsApp/services/conversation_events.dart';

part of map_carto_people;



// ---------- Widgets ----------
class _Bubble extends StatelessWidget {
  const _Bubble({required this.count, required this.size});
  final int count;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '$count',
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
      throw Exception(
        'Erreur conversations/private (${resp.statusCode}) : ${resp.body}',
      );
    }

    final Map<String, dynamic> data = jsonDecode(resp.body);

    final rawId =
        data['id'] ?? data['conversation']?['id'] ?? data['data']?['id'];

    if (rawId is int) return rawId;
    if (rawId is String) return int.parse(rawId);

    throw Exception('ID conversation introuvable');
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
      throw Exception('Erreur envoi message (${resp.statusCode})');
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
      ScaffoldMessenger.of(
        Navigator.of(context, rootNavigator: true).context,
      ).showSnackBar(SnackBar(content: Text('Échec de l’envoi : $e')));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.person;

    final subtitleParts = <String>[];
    if (p.genotype != null && p.genotype!.trim().isNotEmpty) {
      subtitleParts.add(p.genotype!.trim());
    }
    if (p.ageInt != null) {
      subtitleParts.add('${p.ageInt} ans');
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
          leading: GestureDetector(
            onTap: () => widget.onOpenPhoto(photoUrl),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: CachedNetworkImageProvider(
                photoUrl,
                headers: {'X-App-Key': _publicAppKey},
              ),
            ),
          ),
          title: Text(
            p.fullName,
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
                        ? 'C’est votre profil'
                        : 'Envoyer un message…',
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
                      tooltip: _isMe ? 'Impossible de vous écrire' : 'Envoyer',
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
