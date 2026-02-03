import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class ConversationsgroupPage extends StatelessWidget {
  const ConversationsgroupPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Groupes')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Ionicons.construct_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Travail en cours',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 8),
            Text(
              'La fonctionnalité groupes arrive bientôt 🙂',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
