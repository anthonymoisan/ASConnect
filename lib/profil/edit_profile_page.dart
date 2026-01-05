// lib/edit_profile_page.dart
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io' show File, HttpDate; // HttpDate pour parser RFC1123

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;

// =====================
//   CONFIG PUBLIQUE
// =====================

// Clé d'application publique : passer via --dart-define=PUBLIC_APP_KEY=xxx
const String _publicAppKey = String.fromEnvironment(
  'PUBLIC_APP_KEY',
  defaultValue: '',
);

// Base API publique
const String kPublicApiBase =
    'https://anthonymoisan.pythonanywhere.com/api/public';

// Helpers d'URL
String _peopleInfoUrl(int id) => '$kPublicApiBase/people/$id/info';
String _peoplePhotoUrl(int id, int bust) =>
    '$kPublicApiBase/people/$id/photo?b=$bust';
String _peopleUpdateUrl() => '$kPublicApiBase/people/update';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key, required this.personId});
  final int personId;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  static const _maxPhotoBytes = 4 * 1024 * 1024;

  // Form / controllers
  final _formKey = GlobalKey<FormState>();
  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _birthCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _secretAnswerCtrl = TextEditingController();

  final _scrollCtrl = ScrollController();
  final _picker = ImagePicker();

  // State
  bool _loading = true;
  bool _saving = false;

  DateTime? _birthDate;
  String? _genotype;
  double? _lat;
  double? _lon;
  int? _secretQuestionCode;

  String? _photoError;
  String? _photoMime;

  // Photo obligatoire en édition :
  // - on peut supprimer la photo
  // - mais on ne peut pas enregistrer si aucune photo n'existe (ni serveur, ni nouvelle)
  bool _serverHasPhoto = false;
  bool _triedSave = false;

  // Pour cache-buster de l'image serveur
  int _photoBust = DateTime.now().millisecondsSinceEpoch;

  // Nouvelle photo (si choisie)
  XFile? _newPickedFile;
  Uint8List? _newPhotoBytes;
  String? _newPhotoMime;

  // email d'origine (utilisé par /people/update)
  String _originalEmail = '';

  late Map<String, dynamic> _original;

  static const _genotypes = <String>[
    'Délétion',
    'Mutation',
    'UPD',
    'ICD',
    'Clinique',
    'Mosaïque',
  ];

  static const _secretQuestions = <int, String>{
    1: 'Nom de naissance de votre maman ?',
    2: 'Nom de votre acteur de cinéma favori ?',
    3: 'Nom de votre animal de compagnie favori ?',
  };

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _birthCtrl.dispose();
    _emailCtrl.dispose();
    _cityCtrl.dispose();
    _secretAnswerCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) => DateFormat('dd/MM/yyyy', 'fr_FR').format(d);

  DateTime? _parseServerDate(String? s) {
    if ((s ?? '').isEmpty) return null;
    try {
      if (!kIsWeb) return HttpDate.parse(s!);
    } catch (_) {}
    try {
      final df = DateFormat('EEE, dd MMM yyyy HH:mm:ss', 'en_US');
      final dt = df.parseUtc(s!.replaceAll(' GMT', ''));
      return dt.toLocal();
    } catch (_) {}
    return null;
  }

  String? _inferMime(String? filename) {
    final name = (filename ?? '').toLowerCase();
    if (name.endsWith('.png')) return 'image/png';
    if (name.endsWith('.jpg') || name.endsWith('.jpeg')) return 'image/jpeg';
    if (name.endsWith('.webp')) return 'image/webp';
    return null;
  }

  Future<void> _selectPhoto(ImageSource source) async {
    // En sélection de photo, on efface les erreurs (y compris "photo obligatoire")
    setState(() => _photoError = null);
    try {
      final file = await _picker.pickImage(source: source, imageQuality: 92);
      if (file == null) return;

      Uint8List bytes;
      int size;
      if (kIsWeb) {
        bytes = await file.readAsBytes();
        size = bytes.length;
      } else {
        final f = File(file.path);
        size = await f.length();
        bytes = await f.readAsBytes();
      }

      if (size > _maxPhotoBytes) {
        setState(() {
          _newPickedFile = null;
          _newPhotoBytes = null;
          _photoError =
              'La photo dépasse 4 Mo (${(size / (1024 * 1024)).toStringAsFixed(2)} Mo).';
        });
        return;
      }

      setState(() {
        _newPickedFile = file;
        _newPhotoBytes = bytes;
        _newPhotoMime = _inferMime(file.name) ?? 'image/jpeg';
      });
    } catch (e) {
      setState(() => _photoError = 'Impossible de récupérer la photo : $e');
    }
  }

  void _clearNewPhoto() {
    setState(() {
      _newPickedFile = null;
      _newPhotoBytes = null;
      _newPhotoMime = null;
      _photoError = null;
    });
  }

  String? _requiredText(String? v, String label) {
    final s = (v ?? '').trim();
    return s.isEmpty ? '$label requis' : null;
  }

  String? _emailError(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Email requis';
    final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(s);
    return ok ? null : 'Email invalide';
  }

  Map<String, String> get _jsonHeaders => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'X-App-Key': _publicAppKey,
  };

  Map<String, String> get _acceptHeaders => {
    'Accept': 'application/json',
    'X-App-Key': _publicAppKey,
  };

  // ✅ Détecte si la photo existe réellement côté serveur.
  // - Essayez HEAD
  // - si HEAD non supporté (405) -> fallback GET avec Range
  Future<bool> _checkServerPhotoExists() async {
    final uri = Uri.parse(_peoplePhotoUrl(widget.personId, _photoBust));
    try {
      final headResp = await http
          .head(uri, headers: {'X-App-Key': _publicAppKey})
          .timeout(const Duration(seconds: 10));

      if (headResp.statusCode == 200) return true;
      if (headResp.statusCode == 404) return false;

      // 405/403/500… on tente un GET "léger" en fallback
    } catch (_) {
      // ignore -> fallback GET
    }

    try {
      final getResp = await http
          .get(
            uri,
            headers: {
              'X-App-Key': _publicAppKey,
              'Range': 'bytes=0-0', // 1 octet si supporté
            },
          )
          .timeout(const Duration(seconds: 10));

      // 200 ou 206 = OK (200 si Range ignoré, 206 si Range supporté)
      if (getResp.statusCode == 200 || getResp.statusCode == 206) return true;
      if (getResp.statusCode == 404) return false;

      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    try {
      final uri = Uri.parse(_peopleInfoUrl(widget.personId));
      final resp = await http
          .get(uri, headers: _acceptHeaders)
          .timeout(const Duration(seconds: 15));

      if (resp.statusCode != 200) {
        throw Exception('GET ${resp.statusCode}: ${resp.body}');
      }

      final Map<String, dynamic> json =
          jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;

      final first = (json['firstname'] as String?) ?? '';
      final last = (json['lastname'] as String?) ?? '';
      final email = (json['email'] as String?) ?? '';
      final genotype = (json['genotype'] as String?) ?? '';
      final dobStr = (json['dateOfBirth'] as String?) ?? '';
      final dob = _parseServerDate(dobStr);
      final city = (json['city'] as String?) ?? '';
      final lat = (json['latitude'] as num?)?.toDouble();
      final lon = (json['longitude'] as num?)?.toDouble();
      final q = (json['secret_question'] as num?)?.toInt();
      final r = (json['secret_answer'] as String?) ?? '';
      final photoMime = (json['photo_mime'] as String?) ?? 'image/jpeg';

      // ✅ Mise à jour des champs synchrones
      setState(() {
        _firstCtrl.text = first;
        _lastCtrl.text = last;
        _emailCtrl.text = email;
        _originalEmail = email;
        _genotype = _genotypes.contains(genotype) ? genotype : null;
        _birthDate = dob;
        _birthCtrl.text = dob != null ? _formatDate(dob) : '';
        _cityCtrl.text = city;
        _lat = lat;
        _lon = lon;
        _secretQuestionCode = q ?? 1;
        _secretAnswerCtrl.text = r;
        _photoMime = photoMime;

        _original = {
          'firstname': first,
          'lastname': last,
          'emailAddress': email,
          'genotype': _genotype,
          'dateOfBirth': dob?.toIso8601String(),
          'city': city,
          'latitude': lat,
          'longitude': lon,
          'secret_question': _secretQuestionCode,
          'secret_answer': r,
        };

        _photoBust = DateTime.now().millisecondsSinceEpoch;
      });

      // ✅ Check photo serveur (async) hors setState
      final hasPhoto = await _checkServerPhotoExists();
      if (mounted) setState(() => _serverHasPhoto = hasPhoto);
    } on TimeoutException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Timeout en chargeant le profil.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur chargement: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<({double lat, double lon})> _getLatLon() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return (lat: _lat ?? 0.0, lon: _lon ?? 0.0);
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return (lat: _lat ?? 0.0, lon: _lon ?? 0.0);
      }

      try {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 6),
        );
        return (lat: pos.latitude, lon: pos.longitude);
      } on TimeoutException {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null) return (lat: last.latitude, lon: last.longitude);
        return (lat: _lat ?? 0.0, lon: _lon ?? 0.0);
      }
    } catch (_) {
      return (lat: _lat ?? 0.0, lon: _lon ?? 0.0);
    }
  }

  Future<void> _geolocateAndFillCity() async {
    final coords = await _getLatLon();
    String? newCity;

    if (!kIsWeb) {
      try {
        final placemarks = await geocoding.placemarkFromCoordinates(
          coords.lat,
          coords.lon,
        );
        if (placemarks.isNotEmpty) {
          newCity = placemarks.first.locality?.trim();
          newCity ??= placemarks.first.subAdministrativeArea?.trim();
          newCity ??= placemarks.first.administrativeArea?.trim();
        }
      } catch (_) {
        newCity = null;
      }
    }

    setState(() {
      _lat = double.parse(coords.lat.toStringAsFixed(6));
      _lon = double.parse(coords.lon.toStringAsFixed(6));
      if (newCity != null && newCity.isNotEmpty) {
        _cityCtrl.text = newCity!;
      }
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Localisation mise à jour${newCity != null ? ' ($newCity)' : ''}',
        ),
      ),
    );
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final initial = _birthDate ?? DateTime(now.year - 8, now.month, now.day);
    final first = DateTime(1900, 1, 1);
    final last = now;

    final picked = await showDatePicker(
      context: context,
      locale: const Locale('fr'),
      initialDate: initial.isAfter(last) ? last : initial,
      firstDate: first,
      lastDate: last,
      helpText: 'Date de naissance',
      cancelText: 'Annuler',
      confirmText: 'Valider',
    );

    if (picked != null) {
      setState(() {
        _birthDate = picked;
        _birthCtrl.text = _formatDate(picked);
      });
    }
  }

  void _showGeoInfo() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Géolocalisation'),
        content: const Text(
          "Pensez à changer votre géolocalisation si celle-ci a changé "
          "par rapport à votre inscription.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ---------------- Mot de passe: règles ----------------
  bool _pwdHasMinLen(String s) => s.trim().length >= 8;
  bool _pwdHasUpper(String s) => RegExp(r'[A-Z]').hasMatch(s);
  bool _pwdHasSpec(String s) =>
      RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=~;\\/\[\]]').hasMatch(s);

  Widget _pwdRule({required bool ok, required String text}) {
    return Row(
      children: [
        Icon(
          ok ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 18,
          color: ok ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }

  Future<void> _changePasswordDialog() async {
    final ctrl1 = TextEditingController();
    final ctrl2 = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool same = false;

    bool okMin() => _pwdHasMinLen(ctrl1.text);
    bool okUp() => _pwdHasUpper(ctrl1.text);
    bool okSp() => _pwdHasSpec(ctrl1.text);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDlg) {
            same = ctrl1.text == ctrl2.text;
            return AlertDialog(
              title: const Text('Changer mon mot de passe'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: ctrl1,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Nouveau mot de passe',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => setDlg(() {}),
                        validator: (v) {
                          final s = (v ?? '').trim();
                          if (s.isEmpty) return 'Mot de passe requis';
                          if (!okMin() || !okUp() || !okSp()) {
                            return 'Mot de passe trop faible';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _pwdRule(
                              ok: okMin(),
                              text: 'Au moins 8 caractères',
                            ),
                            const SizedBox(height: 4),
                            _pwdRule(ok: okUp(), text: 'Au moins 1 majuscule'),
                            const SizedBox(height: 4),
                            _pwdRule(
                              ok: okSp(),
                              text: 'Au moins 1 caractère spécial',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: ctrl2,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Confirmer le mot de passe',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => setDlg(() {}),
                        validator: (v) {
                          if (ctrl1.text.trim().isEmpty) {
                            return 'Saisis un mot de passe';
                          }
                          if (ctrl1.text != ctrl2.text) {
                            return 'Les mots de passe ne correspondent pas';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            same ? Icons.check_circle : Icons.cancel,
                            size: 18,
                            color: same ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            same
                                ? 'Les mots de passe correspondent'
                                : 'Les mots de passe ne correspondent pas',
                            style: TextStyle(
                              color: same ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Annuler'),
                ),
                FilledButton(
                  onPressed:
                      (okMin() &&
                          okUp() &&
                          okSp() &&
                          same &&
                          ctrl1.text.isNotEmpty)
                      ? () async {
                          if (!formKey.currentState!.validate()) return;
                          try {
                            final uri = Uri.parse(_peopleUpdateUrl());
                            final body = jsonEncode({
                              'emailAddress': _originalEmail,
                              'password': ctrl1.text.trim(),
                            });
                            final resp = await http
                                .patch(uri, headers: _jsonHeaders, body: body)
                                .timeout(const Duration(seconds: 15));
                            if (!(resp.statusCode >= 200 &&
                                resp.statusCode < 300)) {
                              throw Exception('Erreur (${resp.statusCode})');
                            }
                            if (mounted) {
                              Navigator.of(ctx).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Mot de passe changé ✅'),
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Erreur: $e')),
                              );
                            }
                          }
                        }
                      : null,
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deletePhoto() async {
    setState(() => _saving = true);
    try {
      final uri = Uri.parse(_peopleUpdateUrl());
      final body = jsonEncode({
        'emailAddress': _originalEmail,
        'delete_photo': true,
      });
      final resp = await http
          .patch(uri, headers: _jsonHeaders, body: body)
          .timeout(const Duration(seconds: 15));

      if (!(resp.statusCode >= 200 && resp.statusCode < 300)) {
        throw Exception('Erreur (${resp.statusCode})');
      }

      // ✅ Photo supprimée : elle devient obligatoire (il faut en reprendre/importer une)
      setState(() {
        _newPickedFile = null;
        _newPhotoBytes = null;
        _newPhotoMime = null;
        _photoBust = DateTime.now().millisecondsSinceEpoch; // cache-bust

        _serverHasPhoto = false;
        _photoError =
            'Photo obligatoire : importez ou prenez une nouvelle photo.';
      });

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Photo supprimée ✅')));
    } on TimeoutException {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Délai dépassé. Réessaie.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _save() async {
    setState(() => _triedSave = true);

    final hasAnyPhoto =
        (_newPhotoBytes != null && _newPhotoBytes!.isNotEmpty) ||
        _serverHasPhoto;

    if (!hasAnyPhoto) {
      setState(() => _photoError = 'Photo obligatoire');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajoutez une photo pour enregistrer')),
      );
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);
    try {
      final changed = <String, dynamic>{};

      final first = _firstCtrl.text.trim();
      final last = _lastCtrl.text.trim();
      final email = _emailCtrl.text.trim();
      final city = _cityCtrl.text.trim();
      final dobIso = _birthDate?.toIso8601String();

      void addIfChanged(String key, dynamic value) {
        if (_original[key] != value) changed[key] = value;
      }

      addIfChanged('firstname', first);
      addIfChanged('lastname', last);
      addIfChanged('emailAddress', email);
      addIfChanged('genotype', _genotype);
      addIfChanged('dateOfBirth', dobIso);
      addIfChanged('city', city);
      addIfChanged('latitude', _lat);
      addIfChanged('longitude', _lon);
      addIfChanged('secret_question', _secretQuestionCode);
      addIfChanged('secret_answer', _secretAnswerCtrl.text.trim());

      // 1) Si nouvelle photo -> multipart PATCH /people/update
      if (_newPhotoBytes != null && _newPhotoBytes!.isNotEmpty) {
        final req = http.MultipartRequest(
          'PATCH',
          Uri.parse(_peopleUpdateUrl()),
        );
        req.headers['X-App-Key'] = _publicAppKey;
        req.headers['Accept'] = 'application/json';

        req.fields['emailAddress'] = _originalEmail;

        final filename = _newPickedFile?.name ?? 'photo.jpg';
        final mime = _newPhotoMime ?? 'image/jpeg';
        req.files.add(
          http.MultipartFile.fromBytes(
            'photo',
            _newPhotoBytes!,
            filename: filename,
            contentType: http_parser.MediaType.parse(mime),
          ),
        );

        final streamed = await req.send().timeout(const Duration(seconds: 20));
        final resp = await http.Response.fromStream(streamed);
        if (!(resp.statusCode >= 200 && resp.statusCode < 300)) {
          String err = 'Échec (${resp.statusCode})';
          try {
            final p = jsonDecode(utf8.decode(resp.bodyBytes));
            if (p is Map && p['error'] is String) err = p['error'] as String;
          } catch (_) {}
          throw Exception(err);
        }

        setState(() {
          _newPickedFile = null;
          _newPhotoBytes = null;
          _newPhotoMime = null;
          _photoBust = DateTime.now().millisecondsSinceEpoch;

          _serverHasPhoto = true; // ✅ photo à nouveau présente côté serveur
          _photoError = null; // ✅ enlève l’erreur si elle existait
        });
      }

      // 2) Changement d'email (spécifique)
      if (changed.containsKey('emailAddress') &&
          email.isNotEmpty &&
          email != _originalEmail) {
        final uri = Uri.parse(_peopleUpdateUrl());
        final body = jsonEncode({
          'emailAddress': _originalEmail,
          'emailNewAddress': email,
        });
        final resp = await http
            .patch(uri, headers: _jsonHeaders, body: body)
            .timeout(const Duration(seconds: 15));
        if (!(resp.statusCode >= 200 && resp.statusCode < 300)) {
          String err = 'Échec (${resp.statusCode})';
          try {
            final p = jsonDecode(utf8.decode(resp.bodyBytes));
            if (p is Map && p['error'] is String) err = p['error'] as String;
          } catch (_) {}
          throw Exception(err);
        }
        // maj email d'origine
        _originalEmail = email;
        _original['emailAddress'] = email;
        changed.remove('emailAddress');
      }

      // 3) Autres champs via /people/update (par e-mail courant)
      if (changed.isNotEmpty) {
        final payload = <String, dynamic>{'emailAddress': _originalEmail};

        for (final e in changed.entries) {
          final k = e.key;
          final v = e.value;
          if (v == null) continue;

          switch (k) {
            case 'firstname':
            case 'lastname':
            case 'genotype':
            case 'city':
              payload[k] = v;
              break;
            case 'dateOfBirth':
              if (_birthDate != null) {
                payload['dateOfBirth'] = DateFormat(
                  'yyyy-MM-dd',
                ).format(_birthDate!);
              }
              break;
            case 'latitude':
              payload['latitude'] = v;
              break;
            case 'longitude':
              payload['longitude'] = v;
              break;
            case 'secret_question':
              payload['questionSecrete'] = v;
              break;
            case 'secret_answer':
              payload['reponseSecrete'] = v;
              break;
          }
        }

        final resp = await http
            .patch(
              Uri.parse(_peopleUpdateUrl()),
              headers: _jsonHeaders,
              body: jsonEncode(payload),
            )
            .timeout(const Duration(seconds: 15));

        if (!(resp.statusCode >= 200 && resp.statusCode < 300)) {
          String err = 'Échec (${resp.statusCode})';
          try {
            final p = jsonDecode(utf8.decode(resp.bodyBytes));
            if (p is Map && p['error'] is String) err = p['error'] as String;
          } catch (_) {}
          throw Exception(err);
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Modifications enregistrées ✅')),
      );
      Navigator.of(context).pop(true);
    } on TimeoutException {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Délai dépassé. Réessaie.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _cancel() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(false); // false = annulé (optionnel)
    } else {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewInsets = MediaQuery.of(context).viewInsets;
    final photoUrl = _peoplePhotoUrl(widget.personId, _photoBust);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le profil'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Form(
                key: _formKey,
                child: ListView(
                  controller: _scrollCtrl,
                  padding: EdgeInsets.fromLTRB(
                    16,
                    12,
                    16,
                    24 + viewInsets.bottom,
                  ),
                  children: [
                    // Photo (serveur ou nouvelle)
                    Center(
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(80),
                            child: _newPhotoBytes != null
                                ? Image.memory(
                                    _newPhotoBytes!,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  )
                                : Image.network(
                                    photoUrl,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    headers: {'X-App-Key': _publicAppKey},
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 120,
                                      height: 120,
                                      alignment: Alignment.center,
                                      color: Colors.black12,
                                      child: const Icon(
                                        Ionicons.person_circle_outline,
                                        size: 64,
                                      ),
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              OutlinedButton.icon(
                                icon: const Icon(Ionicons.folder_open_outline),
                                label: const Text('Importer'),
                                onPressed: _saving
                                    ? null
                                    : () => _selectPhoto(ImageSource.gallery),
                              ),
                              OutlinedButton.icon(
                                icon: const Icon(Ionicons.camera_outline),
                                label: const Text('Prendre une photo'),
                                onPressed: _saving
                                    ? null
                                    : () => _selectPhoto(ImageSource.camera),
                              ),
                              OutlinedButton.icon(
                                icon: const Icon(Ionicons.trash_outline),
                                label: const Text('Supprimer ma photo'),
                                onPressed: _saving ? null : _deletePhoto,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: theme.colorScheme.error,
                                  side: BorderSide(
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                              ),
                              if (_newPhotoBytes != null)
                                OutlinedButton.icon(
                                  icon: const Icon(
                                    Ionicons.close_circle_outline,
                                  ),
                                  label: const Text('Annuler la sélection'),
                                  onPressed: _saving ? null : _clearNewPhoto,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    if (_photoError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _photoError!,
                        style: TextStyle(color: theme.colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    ],

                    // Optionnel : si tu veux forcer l'affichage après tentative d'enregistrement
                    if (_triedSave &&
                        (_newPhotoBytes == null || _newPhotoBytes!.isEmpty) &&
                        !_serverHasPhoto &&
                        _photoError == null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Photo obligatoire',
                        style: TextStyle(color: theme.colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    ],

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Icon(
                          Ionicons.person_circle_outline,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Informations du profil',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Prénom
                    TextFormField(
                      controller: _firstCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Prénom',
                        prefixIcon: Icon(Ionicons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => _requiredText(v, 'Prénom'),
                    ),
                    const SizedBox(height: 12),

                    // Nom
                    TextFormField(
                      controller: _lastCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Nom',
                        prefixIcon: Icon(Ionicons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => _requiredText(v, 'Nom'),
                    ),
                    const SizedBox(height: 12),

                    // Email
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'Adresse e-mail',
                        prefixIcon: Icon(Ionicons.mail),
                        border: OutlineInputBorder(),
                      ),
                      validator: _emailError,
                    ),
                    const SizedBox(height: 12),

                    // Date de naissance
                    TextFormField(
                      controller: _birthCtrl,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Date de naissance (jj/mm/aaaa)',
                        prefixIcon: const Icon(Ionicons.calendar),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          tooltip: 'Choisir une date',
                          icon: const Icon(Ionicons.calendar_clear),
                          onPressed: _pickBirthDate,
                        ),
                      ),
                      onTap: _pickBirthDate,
                      validator: (_) => _birthDate == null
                          ? 'Date de naissance requise'
                          : null,
                    ),
                    const SizedBox(height: 12),

                    // Génotype
                    DropdownButtonFormField<String>(
                      value: _genotype,
                      isExpanded: true,
                      borderRadius: BorderRadius.circular(12),
                      decoration: const InputDecoration(
                        labelText: 'Génotype',
                        prefixIcon: Icon(Ionicons.git_branch),
                        border: OutlineInputBorder(),
                      ),
                      items: _genotypes
                          .map(
                            (g) => DropdownMenuItem(value: g, child: Text(g)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _genotype = v),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Génotype requis' : null,
                    ),
                    const SizedBox(height: 12),

                    // Ville non éditable + bouton géolocaliser + icône info
                    TextFormField(
                      controller: _cityCtrl,
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: 'Ville',
                        prefixIcon: Icon(Ionicons.business_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OutlinedButton.icon(
                          icon: const Icon(Ionicons.locate_outline),
                          label: const Text('Me géolocaliser'),
                          onPressed: _saving ? null : _geolocateAndFillCity,
                        ),
                        const SizedBox(width: 8),
                        Tooltip(
                          message:
                              "Pensez à changer votre géolocalisation si celle-ci a changé par rapport à votre inscription.",
                          child: IconButton(
                            onPressed: _showGeoInfo,
                            icon: const Icon(
                              Ionicons.information_circle_outline,
                            ),
                            tooltip:
                                "Pensez à changer votre géolocalisation si celle-ci a changé par rapport à votre inscription.",
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Secret Q/R
                    Row(
                      children: [
                        Icon(
                          Ionicons.lock_closed_outline,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Question secrète',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<int>(
                      value: _secretQuestionCode ?? 1,
                      isExpanded: true,
                      borderRadius: BorderRadius.circular(12),
                      decoration: const InputDecoration(
                        labelText: 'Question',
                        prefixIcon: Icon(Ionicons.help_circle_outline),
                        border: OutlineInputBorder(),
                      ),
                      items: _secretQuestions.entries
                          .map(
                            (e) => DropdownMenuItem<int>(
                              value: e.key,
                              child: Text(e.value),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() {
                        _secretQuestionCode = v ?? 1;
                        _secretAnswerCtrl.clear();
                      }),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _secretAnswerCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Réponse secrète',
                        prefixIcon: Icon(Ionicons.chatbox_ellipses_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => _requiredText(v, 'Réponse'),
                    ),

                    const SizedBox(height: 12),

                    // Changer mot de passe
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        icon: const Icon(Ionicons.key_outline),
                        label: const Text('Changer mon mot de passe'),
                        onPressed: _saving ? null : _changePasswordDialog,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Actions: Annuler / Enregistrer
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Ionicons.close_circle_outline),
                            label: const Text('Annuler'),
                            onPressed: _saving ? null : _cancel,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            icon: _saving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Ionicons.save_outline),
                            label: Text(
                              _saving ? 'Enregistrement…' : 'Enregistrer',
                            ),
                            onPressed: _saving ? null : _save,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
