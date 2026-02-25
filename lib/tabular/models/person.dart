class Person {
  final int id;

  final String firstName;
  final String lastName;

  final int? age;

  final String? city;
  final String? country;
  final String? countryCode;

  /// ✅ Langue (ex: "fr", "en", "de")
  final String? lang;

  final String? genotype;

  final double? latitude;
  final double? longitude;

  /// Statut de connexion (online / offline)
  final bool isConnected;

  const Person({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.age,
    this.city,
    this.country,
    this.countryCode,
    this.lang,
    this.genotype,
    this.latitude,
    this.longitude,
    required this.isConnected,
  });

  // ---------------------------------------------------------------------------
  // JSON
  // ---------------------------------------------------------------------------
  static bool _parseIsConnected(dynamic v) {
    if (v == null) return false;
    if (v is bool) return v;
    if (v is num) return v != 0;
    final s = v.toString().trim().toLowerCase();
    return s == '1' || s == 'true' || s == 'yes';
  }

  static String? _parseLang(dynamic v) {
    final s = v?.toString().trim();
    if (s == null || s.isEmpty) return null;
    return s.toLowerCase(); // normalisation
  }

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'] as int,

      firstName: json['firstname'] as String,
      lastName: json['lastname'] as String,

      age: json['age'] as int?,

      city: json['city'] as String?,
      country: json['country'] as String?,
      countryCode: json['country_code'] as String?,

      // ✅ accepte plusieurs clés possibles côté API
      lang: _parseLang(json['lang'] ?? json['language'] ?? json['locale']),

      genotype: json['genotype'] as String?,

      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),

      isConnected: _parseIsConnected(json['is_connected']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstname': firstName,
      'lastname': lastName,
      'age': age,
      'city': city,
      'country': country,
      'country_code': countryCode,
      'lang': lang,
      'genotype': genotype,
      'latitude': latitude,
      'longitude': longitude,
      'is_connected': isConnected ? 1 : 0,
    };
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String get fullName => '$firstName $lastName';

  bool get hasLocation => latitude != null && longitude != null;

  String get pseudo {
    if (lastName.isEmpty) return firstName;
    return '$firstName ${lastName[0].toUpperCase()}';
  }

  @override
  String toString() {
    return 'Person(id: $id, name: $fullName, lang: $lang, city: $city, online: $isConnected)';
  }
}
