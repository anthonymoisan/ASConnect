import 'package:flutter/material.dart';

import '../models/listPerson.dart'; // adapte si ton fichier s'appelle list_person.dart
import '../services/tabular_api.dart'; // adapte si ton fichier s'appelle autrement

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
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(body: Center(child: Text('Error: $_error')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Tabular view')),
      body: Center(
        child: Text(
          'Loaded ${_listPerson?.count ?? 0} people',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
