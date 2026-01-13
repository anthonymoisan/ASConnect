import 'person.dart';

class ListPerson {
  final List<Person> items;

  const ListPerson({required this.items});

  // ---------------------------------------------------------------------------
  // 🔁 Factory : depuis une liste JSON
  // ---------------------------------------------------------------------------
  factory ListPerson.fromJsonList(List<dynamic> jsonList) {
    final persons = jsonList
        .whereType<Map<String, dynamic>>()
        .map(Person.fromJson)
        .toList();

    return ListPerson(items: persons);
  }

  // ---------------------------------------------------------------------------
  // 📊 Helpers utiles
  // ---------------------------------------------------------------------------

  int get count => items.length;

  int get onlineCount => items.where((p) => p.isConnected).length;

  int get offlineCount => items.where((p) => !p.isConnected).length;

  List<Person> get onlineOnly => items.where((p) => p.isConnected).toList();

  List<Person> get offlineOnly => items.where((p) => !p.isConnected).toList();

  // ---------------------------------------------------------------------------
  // 🌍 Filtres pratiques
  // ---------------------------------------------------------------------------

  List<Person> byCity(String city) =>
      items.where((p) => p.city == city).toList();

  List<Person> byCountryCode(String code) =>
      items.where((p) => p.countryCode == code).toList();

  // ---------------------------------------------------------------------------
  // 🔎 Recherche simple
  // ---------------------------------------------------------------------------

  List<Person> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return items;

    return items.where((p) {
      return p.firstName.toLowerCase().contains(q) ||
          p.lastName.toLowerCase().contains(q) ||
          p.city?.toLowerCase().contains(q) == true ||
          p.country?.toLowerCase().contains(q) == true;
    }).toList();
  }
}
