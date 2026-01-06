//photo viewer

part of map_carto_people;

extension _MapPeoplePhoto on _MapPeopleByCityState {
  // --- Visionneuse photo plein écran (modale) ---
  Future<void> _showPhotoViewer(String url) async {
    final l10n = AppLocalizations.of(context)!;

    await showGeneralDialog(
      context: context,
      barrierLabel: l10n.mapPhotoViewerBarrierLabel,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.9),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (ctx, a1, a2) {
        final l10n2 = AppLocalizations.of(ctx)!;
        return SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(onTap: () => Navigator.of(ctx).pop()),
              ),
              Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.network(
                    url,
                    headers: {'X-App-Key': _publicAppKey},
                    fit: BoxFit.contain,
                    loadingBuilder: (c, child, prog) => prog == null
                        ? child
                        : const CircularProgressIndicator(),
                    errorBuilder: (c, e, s) => const Icon(
                      Icons.broken_image,
                      size: 72,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 12,
                top: 12,
                child: IconButton(
                  tooltip: l10n2.mapClose,
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ),
            ],
          ),
        );
      },
      transitionBuilder: (ctx, anim, _, child) =>
          FadeTransition(opacity: anim, child: child),
    );
  }
}
