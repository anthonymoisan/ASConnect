// lib/mapCartoPeople/mapCartoPeople_state.dart
part of map_carto_people;

class _MapPeopleByCityState extends State<MapPeopleByCity>
    with AutomaticKeepAliveClientMixin<MapPeopleByCity> {
  @override
  bool get wantKeepAlive => true;

  // Controller
  final MapController _map = MapController();

  // ---------------------------------------------------------------------------
  // Data sources
  // ---------------------------------------------------------------------------

  // Source filtrée globale (après application des filtres)
  // Sert de base au drilldown pays -> villes
  List<_CityCluster> _filteredAllClusters = <_CityCluster>[];

  // i18n country labels (ISO2 -> translated name)
  Map<String, String> _countryLabelsByIso2 = <String, String>{};
  String? _countryLabelsLocale;
  bool _loadingCountryLabels = false;

  bool _didInitialFit = false;

  // Vue initiale (France / Europe)
  final _initialCenter = const LatLng(48.8566, 2.3522);
  final double _initialZoom = 5.5;

  double _lastMarkerScale = 1.0;

  // Debounce map events (used by UI)
  Timer? _mapEventDebounce;

  // Used by TileLayer (must match the constant you use in UI)
  // If your UI uses `kUserAgentPackageName`, keep it consistent here.
  static const String kUserAgentPackageName = 'fr.asconnexion.app';

  // UI state
  bool _loading = false;
  String? _error;

  // Prevent parallel loads
  bool _loadingInProgress = false;

  // Init overlay (mask map at first load)
  bool _initializing = true;
  bool _firstLoadTried = false;

  // Clusters: current (filtered view) vs source (no filters)
  List<_CityCluster> _clusters = <_CityCluster>[];
  List<_CityCluster> _allClusters = <_CityCluster>[];

  // Cache in memory (clusters structure)
  List<_CityCluster>? _clustersCache;
  DateTime? _clustersCacheTime;
  static const Duration _cacheTtl = Duration(minutes: 10);

  bool get _cacheIsFresh =>
      _clustersCache != null &&
      _clustersCacheTime != null &&
      DateTime.now().difference(_clustersCacheTime!) < _cacheTtl;

  // Markers
  int _markersSignature = 0;

  // IMPORTANT: not final because we may replace the list reference
  // (useful if you go back to MarkerClusterLayerWidget later)
  List<Marker> _cityMarkers = <Marker>[];

  // Connected-only filter (if you use it server-side)
  bool _connectedOnly = false;

  // ---------------------------------------------------------------------------
  // Filters
  // ---------------------------------------------------------------------------

  // Filtres (valeurs attendues côté API)
  static const List<String> kGenotypeOptions = <String>[
    'Délétion',
    'Mutation',
    'UPD',
    'ICD',
    'Clinique',
    'Mosaïque',
  ];

  final Set<String> _selectedGenotypes = <String>{}; // tous cochés par défaut

  int? _datasetMinAge;
  int? _datasetMaxAge;
  int? _selectedMinAge;
  int? _selectedMaxAge;

  // Distance filter (km) from user position
  LatLng? _distanceOrigin;
  double? _maxDistanceKm;
  bool _distanceFilterEnabled = false;
  final Distance _geo = const Distance();

  // Bubble sizes used by marker builder (make sure markers file uses same consts)
  // If your markers file uses kMinSize/kMaxSize/kSizeCurveGamma, keep those constants
  // in a shared place. Here we keep the same names to reduce confusion.
  static const double kMinSize = 20.0;
  static const double kMaxSize = 52.0;
  static const double kSizeCurveGamma = 0.65;

  // Zoom dynamic scaling
  double _currentZoom = 5.5;

  double get _zoomFactor {
    final dz = _currentZoom - _initialZoom;
    final f = math.pow(2.0, dz * 0.17).toDouble(); // ~ +12-13% / cran
    return f.clamp(0.6, 2.0);
  }

  int _lastFitSig = 0;
  int _lastCityFitSig = 0;

  // Count after filters
  int get _peopleCount {
    if (_level == _MapLevel.country) {
      return _countryClusters.fold<int>(0, (sum, c) => sum + c.count);
    }
    return _clusters.fold<int>(0, (sum, c) => sum + c.count);
  }

  // Country options from dataset
  List<String> _countryOptions = <String>[];
  final Set<String> _selectedCountries = <String>{};

  // Drill-down
  _MapLevel _level = _MapLevel.country;
  String? _activeCountry; // ISO2
  List<_CountryCluster> _countryClusters = <_CountryCluster>[];

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

    // Default: all genotypes selected
    _selectedGenotypes
      ..clear()
      ..addAll(kGenotypeOptions);

    _currentZoom = _initialZoom;

    // Country labels: use full locale (ex: pt_BR) when available, not just languageCode.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _ensureCountryLabelsForLocale(context);
    });

    // First load
    _loadAndBuild(); // in state_data.dart
  }

  @override
  void dispose() {
    // ✅ avoid timers firing after widget is gone
    _mapEventDebounce?.cancel();
    _mapEventDebounce = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // IMPORTANT for keep-alive
    return buildMapPeopleUI(context);
  }

  // Fit after frame (legacy helper)
  void _fitOnNextFrameOnce(List<_CityCluster> clusters) {
    if (_didInitialFit) return;
    if (clusters.isEmpty) return;

    _didInitialFit = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _fitMapToClusters(clusters);
    });
  }
}
