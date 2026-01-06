// lib/mapCartoPeople_models.dart
part of map_carto_people;

// ---------- Modèles ----------
class _Person {
  final int? id;
  final String? firstname;
  final String? lastname;
  final String? city;
  final String? country;
  final String? countryCode;
  final double? latitude;
  final double? longitude;
  final int? ageInt; // âge (années)
  final String? genotype;

  _Person({
    this.id,
    this.firstname,
    this.lastname,
    this.city,
    this.country,
    this.countryCode,
    this.latitude,
    this.longitude,
    this.ageInt,
    this.genotype,
  });

  factory _Person.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse('$v');
    }

    final lat = parseDouble(json['latitude'] ?? json['lat']);
    final lon = parseDouble(json['longitude'] ?? json['lon']);

    return _Person(
      id: json['id'] is num
          ? (json['id'] as num).toInt()
          : int.tryParse('${json['id']}'),
      firstname: json['firstname']?.toString(),
      lastname: json['lastname']?.toString(),
      city: json['city']?.toString(),
      country: json['country']?.toString(),
      countryCode: json['country_code']?.toString(),
      latitude: lat,
      longitude: lon,
      ageInt: _parseAgeInt(json['age']),
      genotype: json['genotype']?.toString(),
    );
  }

  String get fullName {
    final f = (firstname ?? '').trim();
    final l = (lastname ?? '').trim();
    if (f.isEmpty && l.isEmpty) return 'Anonyme';
    if (f.isEmpty) return l;
    if (l.isEmpty) return f;
    return '$f $l';
  }
}

class _CityCluster {
  final String city;
  final LatLng latLng;
  final List<_Person> people;

  _CityCluster({
    required this.city,
    required this.latLng,
    required this.people,
  });

  int get count => people.length;
}

int? _parseAgeInt(dynamic value) {
  if (value == null) return null;
  final s = value.toString().trim().replaceAll(',', '.');
  final d = double.tryParse(s);
  if (d == null) return null;
  return d.round();
}
