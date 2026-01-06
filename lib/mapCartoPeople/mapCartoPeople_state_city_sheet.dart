//clic bulle → bottomsheet ville
part of map_carto_people;

extension _MapPeopleCitySheet on _MapPeopleByCityState {
  // BottomSheet Ville
  Future<void> _openCitySheet(_CityCluster cluster) async {
    final l10n = AppLocalizations.of(context)!;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final l10n2 = AppLocalizations.of(ctx)!;
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom,
            top: 16,
          ),
          child: SafeArea(
            top: false,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 520),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Ionicons.business),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n2.mapCityPeopleCount(cluster.city, cluster.count),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.separated(
                      itemCount: cluster.people.length,
                      separatorBuilder: (_, __) =>
                          Divider(height: 12, color: Colors.grey.shade200),
                      itemBuilder: (ctx, i) {
                        final p = cluster.people[i];
                        return _PersonTile(
                          person: p,
                          currentPersonId: widget.currentPersonId,
                          buildPhotoUrl: () => _personPhotoUrl(p.id ?? -1),
                          onOpenPhoto: (url) => _showPhotoViewer(url),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
