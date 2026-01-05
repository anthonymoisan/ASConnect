// lib/mapCartoPeople_overlays.dart
part of map_carto_people;

// Loader plein écran
class _PositionedFillLoader extends StatelessWidget {
  const _PositionedFillLoader({super.key});
  @override
  Widget build(BuildContext context) {
    return const PositionedFill(
      child: IgnorePointer(
        ignoring: true,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

// Écran d'initialisation (masque totalement la carte)
class _InitOverlay extends StatelessWidget {
  final String message;
  const _InitOverlay({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return PositionedFill(
      child: Material(
        color: Colors.white,
        child: IgnorePointer(
          ignoring: true,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const LinearProgressIndicator(minHeight: 4),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Hack utile : Positioned.fill n'est pas const dans toutes versions
class PositionedFill extends StatelessWidget {
  final Widget child;
  const PositionedFill({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return Positioned(left: 0, right: 0, top: 0, bottom: 0, child: child);
  }
}
