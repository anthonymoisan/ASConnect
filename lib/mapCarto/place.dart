// lib/mapCarto/place.dart

enum PlaceType { ime, phar, mas, fam, mdph, camps, remarkable }

class Place {
  final PlaceType type;
  final String? name;
  final String? address;
  final String? phone;
  final double? lat;
  final double? lon;

  Place({
    required this.type,
    this.name,
    this.address,
    this.phone,
    this.lat,
    this.lon,
  });

  factory Place.fromJson(Map<String, dynamic> json, PlaceType type) {
    final coord = (json['coord'] is Map)
        ? (json['coord'] as Map).cast<String, dynamic>()
        : null;

    final lat = toDoubleOrNull(
      coord?['lat'] ?? json['lat'] ?? json['latitude'],
    );
    final lon = toDoubleOrNull(
      coord?['lon'] ?? json['lon'] ?? json['lng'] ?? json['longitude'],
    );

    final name =
        (json['rslongue'] ??
                json['rs_longue'] ??
                json['name'] ??
                json['label'] ??
                json['title'] ??
                json['Nom'])
            ?.toString();

    final address =
        (json['adresse'] ?? json['address'] ?? json['addr'] ?? json['Adresse'])
            ?.toString();

    final phone =
        (json['telephone'] ?? json['tel'] ?? json['phone'] ?? json['Téléphone'])
            ?.toString();

    return Place(
      type: type,
      name: name,
      address: address,
      phone: phone,
      lat: lat,
      lon: lon,
    );
  }
}

double? toDoubleOrNull(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v.replaceAll(',', '.'));
  return null;
}
