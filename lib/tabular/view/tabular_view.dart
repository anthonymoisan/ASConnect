import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../l10n/app_localizations.dart'; // si tu veux traduire, sinon retire
import '../models/listPerson.dart';
import '../models/person.dart';
import '../services/tabular_api.dart';
import '../../whatsApp/services/conversation_api.dart'
    show personPhotoUrl, publicAppKey;

class TabularView extends StatefulWidget {
  const TabularView({super.key});

  @override
  State<TabularView> createState() => _TabularViewState();
}

class _TabularViewState extends State<TabularView> {
  ListPerson? _listPerson;
  bool _loading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await TabularApi.fetchPeopleMapRepresentation();
      if (!mounted) return;

      debugPrint('[TABULAR] people count = ${data.count}');

      setState(() {
        _listPerson = data;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final people = _listPerson?.items ?? const <Person>[];

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Table')),
        body: Center(child: Text('Error: $_error')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Table (${people.length})')),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _loading = true;
            _error = null;
          });
          await _load();
        },
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: people.length,
          separatorBuilder: (_, __) =>
              Divider(height: 1, color: Colors.grey.shade200),
          itemBuilder: (ctx, i) {
            final p = people[i];

            final pseudo =
                p.pseudo; // ton getter "firstname + ' ' + initial lastname"
            final age = (p.age == null) ? '—' : '${p.age}';
            final city = (p.city == null || p.city!.trim().isEmpty)
                ? '—'
                : p.city!.trim();
            final country = (p.country == null || p.country!.trim().isEmpty)
                ? ''
                : p.country!.trim();

            final location = country.isEmpty ? city : '$city • $country';

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: _PeoplePhotoAvatar(
                peopleId: p.id,
                radius: 22,
                onTap: null, // tu pourras ouvrir une photo fullscreen plus tard
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      pseudo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    age,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              subtitle: Text(
                location,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade700),
              ),
              onTap: () {
                debugPrint('[TABULAR] tap person id=${p.id} pseudo=$pseudo');
              },
            );
          },
        ),
      ),
    );
  }
}

// ============================================================================
// ✅ Avatar robuste : fetch bytes avec header X-App-Key => Image.memory
// (copie identique à ce que tu as déjà dans ConversationsPage)
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
          if (bytes == null) return avatarFallback();

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
