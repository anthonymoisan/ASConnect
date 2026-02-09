// lib/tabular/widgets/person_avatar_with_status.dart

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../whatsApp/services/conversation_api.dart' show publicAppKey;

class PersonAvatarWithStatus extends StatelessWidget {
  final String url;
  final bool isConnected;
  final VoidCallback? onTap;
  final double radius;

  const PersonAvatarWithStatus({
    super.key,
    required this.url,
    required this.isConnected,
    this.onTap,
    this.radius = 18,
  });

  @override
  Widget build(BuildContext context) {
    final box = radius * 2;

    final dotSize = (radius * 0.55).clamp(10.0, 14.0).toDouble();
    final dotPadding = (radius * 0.12).clamp(1.0, 4.0).toDouble();

    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      width: box,
      height: box,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.center,
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: ClipOval(
                child: Image.network(
                  url,
                  headers: const {'X-App-Key': publicAppKey},
                  width: box,
                  height: box,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: box,
                    height: box,
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.person,
                      size: radius * 1.1,
                      color: Colors.black45,
                    ),
                  ),
                  loadingBuilder: (ctx, child, prog) {
                    if (prog == null) return child;
                    return Container(
                      width: box,
                      height: box,
                      color: Colors.grey.shade200,
                      alignment: Alignment.center,
                      child: const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Positioned(
            right: dotPadding,
            top: dotPadding,
            child: Tooltip(
              message: isConnected ? l10n.statusOnline : l10n.statusOffline,
              child: Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  color: isConnected ? Colors.green : Colors.red,
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
            ),
          ),
        ],
      ),
    );
  }
}
