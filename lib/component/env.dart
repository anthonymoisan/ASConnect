// lib/env.dart
class Env {
  // Hôte
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://anthonymoisan.pythonanywhere.com',
  );

  // Clé publique pour les endpoints "public"
  static const publicAppKey = String.fromEnvironment('PUBLIC_APP_KEY');

  // Identifiants privés (communs V5 & V6)
  static const privateUsername = String.fromEnvironment('PRIVATE_USERNAME');
  static const privatePassword = String.fromEnvironment('PRIVATE_PASSWORD');
}
