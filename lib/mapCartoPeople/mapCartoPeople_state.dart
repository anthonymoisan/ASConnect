// lib/mapCartoPeople/mapCartoPeople_state.dart
part of map_carto_people;

class _MapPeopleByCityState extends State<MapPeopleByCity>
    with AutomaticKeepAliveClientMixin<MapPeopleByCity> {
  @override
  bool get wantKeepAlive => true;

  final _map = MapController();

  // Source filtrée globale (après application des filtres)
  // Sert de base au drilldown pays -> villes
  List<_CityCluster> _filteredAllClusters = [];

  Map<String, String> _countryLabelsByIso2 = {}; // ISO2 -> name translated
  String? _countryLabelsLocale;
  bool _loadingCountryLabels = false;

  bool _didInitialFit = false;

  // Vue initiale (France / Europe)
  final _initialCenter = const LatLng(48.8566, 2.3522);
  final double _initialZoom = 5.5;

  static const _userAgentPackageName = 'fr.asconnexion.app';

  bool _loading = false;
  String? _error;

  // Pour éviter les appels parallèles
  bool _loadingInProgress = false;

  // Écran d'initialisation (masque la carte + tuiles grises au tout début)
  bool _initializing = true; // tant que la 1ère charge n’est pas finie
  bool _firstLoadTried = false;

  // Données agrégées par ville (courantes vs source)
  List<_CityCluster> _clusters = []; // vue courante (après filtres)
  List<_CityCluster> _allClusters = []; // source (sans filtres)

  // --- CACHE en mémoire de la structure des clusters ---
  List<_CityCluster>? _clustersCache;
  DateTime? _clustersCacheTime;
  static const Duration _cacheTtl = Duration(minutes: 10);
  bool get _cacheIsFresh =>
      _clustersCache != null &&
      _clustersCacheTime != null &&
      DateTime.now().difference(_clustersCacheTime!) < _cacheTtl;

  // Marqueurs pour clustering
  final List<Marker> _cityMarkers = [];

  // Filtres (valeurs attendues côté API)
  static const List<String> _genotypeOptions = <String>[
    'Délétion',
    'Mutation',
    'UPD',
    'ICD',
    'Clinique',
    'Mosaïque',
  ];
  final Set<String> _selectedGenotypes = {}; // tous cochés par défaut
  int? _datasetMinAge;
  int? _datasetMaxAge;
  int? _selectedMinAge;
  int? _selectedMaxAge;

  // Distance (km) depuis position utilisateur
  LatLng? _distanceOrigin;
  double? _maxDistanceKm;
  bool _distanceFilterEnabled = false;
  final Distance _geo = const Distance();

  // Tailles bulles
  static const double _minSize = 20.0;
  static const double _maxSize = 52.0;
  // Courbure taille (gamma) — <1 gonfle petits cercles
  static const double _sizeCurveGamma = 0.65;

  // Zoom dynamique
  double _currentZoom = 5.5; // maj via onMapEvent
  double get _zoomFactor {
    final dz = _currentZoom - _initialZoom;
    final f = math.pow(2.0, dz * 0.17).toDouble(); // ~ +12-13% / cran
    return f.clamp(0.6, 2.0);
  }

  // Compteur de personnes (après filtres)
  int get _peopleCount {
    // Au niveau pays : on veut le total sur TOUS les pays filtrés (country clusters visibles)
    if (_level == _MapLevel.country) {
      return _countryClusters.fold<int>(0, (sum, c) => sum + c.count);
    }
    // Au niveau ville : total sur les villes visibles (clusters de villes)
    return _clusters.fold<int>(0, (sum, c) => sum + c.count);
  }

  // Pays (options dynamiques depuis le dataset)
  List<String> _countryOptions = [];
  final Set<String> _selectedCountries = {}; // tous cochés par défaut

  _MapLevel _level = _MapLevel.country;
  String? _activeCountry; // ISO2 du pays drill-down
  List<_CountryCluster> _countryClusters = [];

  @override
  void initState() {
    super.initState();

    assert(
      _publicAppKey.isNotEmpty,
      '⚠️ PUBLIC_APP_KEY manquante. Lance l’app avec '
      '--dart-define=PUBLIC_APP_KEY=... pour accéder à /api/public/*',
    );

    _level = _MapLevel.country;
    _activeCountry = null;

    // Par défaut : TOUS les génotypes cochés
    _selectedGenotypes.addAll(kGenotypeOptions);
    _currentZoom = _initialZoom;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _ensureCountryLabelsForLocale(context);
    });
    _loadAndBuild(); // première charge (dans state_data.dart)
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // IMPORTANT pour keep-alive
    return buildMapPeopleUI(context); // ✅ dans state_ui.dart
  }

  void _fitOnNextFrameOnce(List<_CityCluster> clusters) {
    if (_didInitialFit) return;
    if (clusters.isEmpty) return;

    _didInitialFit = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _fitMapToClusters(clusters); // ta fonction déjà créée
    });
  }
}
