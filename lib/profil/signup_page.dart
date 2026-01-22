// lib/signup_page.dart
import 'dart:async';
import 'dart:io' show File;
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;
import 'package:geolocator/geolocator.dart';

// ✅ AppLocalizations
import '../l10n/app_localizations.dart';

// =====================
//   CONFIG PUBLIQUE
// =====================
const String _publicAppKey = String.fromEnvironment(
  'PUBLIC_APP_KEY',
  defaultValue: '',
);

const String kPublicApiBase =
    'https://anthonymoisan.pythonanywhere.com/api/public';

Uri _publicSignupUri() => Uri.parse('$kPublicApiBase/people');

class SignUpData {
  /// ✅ Champ API: "M" ou "F"
  final String gender;

  final String firstName;
  final String lastName;
  final DateTime birthDate;
  final String genotype; // envoyé à l’API (valeur FR)
  final String email;
  final String password;
  final Uint8List? photoBytes;
  final String? photoFilename;
  final String? photoMimeType;
  final String secretQuestion; // label UI
  final String secretAnswer;
  final bool consent;

  // ✅ NOUVEAU : opt-in infos Angelman (API: is_info 1/0)
  final bool acceptAngelmanInfo;

  SignUpData({
    required this.gender,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.genotype,
    required this.email,
    required this.password,
    this.photoBytes,
    this.photoFilename,
    this.photoMimeType,
    required this.secretQuestion,
    required this.secretAnswer,
    required this.consent,
    required this.acceptAngelmanInfo,
  });
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key, this.onSubmit});
  final Future<void> Function(SignUpData data)? onSubmit;

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  static const int _maxPhotoBytes = 4 * 1024 * 1024; // 4 Mo

  final _formKey = GlobalKey<FormState>();

  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _birthCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  final _secretAnswerCtrl = TextEditingController();

  final _listCtrl = ScrollController();
  final _secretAnswerFocus = FocusNode();
  final _secretAnswerKey = GlobalKey();

  DateTime? _birthDate;

  // ✅ Sexe: on stocke une clé UI ("male"/"female") et on mappe vers "M"/"F" pour l'API
  String? _genderKey; // "male" | "female"

  // 🔐 On stocke des "codes" UI pour afficher des labels localisés
  // et on mappe vers la valeur FR attendue par l'API.
  String? _genotypeKey; // ex: deletion / mutation / upd...
  int? _secretQuestionIndex; // 0..2

  bool _obscure = true;
  bool _submitting = false;

  bool _consent = false;

  // ✅ NOUVEAU : 2e checkbox (optionnelle)
  bool _acceptAngelmanInfo = false;

  bool _triedSubmit = false;

  final ImagePicker _picker = ImagePicker();
  XFile? _pickedFile;
  Uint8List? _photoBytes;
  String? _photoError;

  // --- Génotypes (clé UI -> valeur API FR) ---
  static const Map<String, String> _genotypeApiValueFr = {
    'deletion': 'Délétion',
    'mutation': 'Mutation',
    'upd': 'UPD',
    'icd': 'ICD',
    'clinical': 'Clinique',
    'mosaic': 'Mosaïque',
  };

  // --- Sexe (clé UI -> valeur API) ---
  static const Map<String, String> _genderApiValue = {
    'male': 'M',
    'female': 'F',
  };

  // ----------- GEOLOCALISATION -----------
  Future<({double lat, double lon})> _getLatLon() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return (lat: 0.0, lon: 0.0);
      }

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return (lat: 0.0, lon: 0.0);
      }

      try {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 6),
        );
        return (lat: pos.latitude, lon: pos.longitude);
      } on TimeoutException {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null) {
          return (lat: last.latitude, lon: last.longitude);
        }
        return (lat: 0.0, lon: 0.0);
      }
    } catch (_) {
      return (lat: 0.0, lon: 0.0);
    }
  }

  @override
  void initState() {
    super.initState();
    _pwdCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _birthCtrl.dispose();
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    _secretAnswerCtrl.dispose();
    _listCtrl.dispose();
    _secretAnswerFocus.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) {
    final localeName = Localizations.localeOf(context).toString();
    return DateFormat.yMd(localeName).format(d);
  }

  String? _requiredText(String? v, String requiredMsg) {
    final s = (v ?? '').trim();
    return s.isEmpty ? requiredMsg : null;
  }

  String? _emailError(String? v) {
    final t = AppLocalizations.of(context)!;
    final s = (v ?? '').trim();
    if (s.isEmpty) return t.emailHintRequired;
    final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(s);
    return ok ? null : t.emailHintInvalid;
  }

  bool get _passHasMinLen => _pwdCtrl.text.trim().length >= 8;
  bool get _passHasUpper => RegExp(r'[A-Z]').hasMatch(_pwdCtrl.text);
  bool get _passHasDigit => RegExp(r'\d').hasMatch(_pwdCtrl.text);
  bool get _passHasSpec =>
      RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=~;\\/\[\]]').hasMatch(_pwdCtrl.text);

  String? _passwordError(String? v) {
    final t = AppLocalizations.of(context)!;
    final s = (v ?? '').trim();
    if (s.isEmpty) return t.passwordRequired;
    if (_passHasMinLen && _passHasUpper && _passHasDigit && _passHasSpec) {
      return null;
    }
    return t.signupPasswordTooWeak;
  }

  Future<void> _pickBirthDate() async {
    final t = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final initial = _birthDate ?? DateTime(now.year - 8, now.month, now.day);
    final first = DateTime(1900, 1, 1);
    final last = now;

    final locale = Localizations.localeOf(context);

    final picked = await showDatePicker(
      context: context,
      locale: locale,
      initialDate: initial.isAfter(last) ? last : initial,
      firstDate: first,
      lastDate: last,
      helpText: t.signupBirthdateHelp,
      cancelText: t.cancel,
      confirmText: t.confirm,
    );

    if (picked != null) {
      setState(() {
        _birthDate = picked;
        _birthCtrl.text = _formatDate(picked);
      });
    }
  }

  Future<void> _selectPhoto(ImageSource source) async {
    final t = AppLocalizations.of(context)!;

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
          _pickedFile = null;
          _photoBytes = null;
          _photoError = t.signupPhotoTooLarge(
            (size / (1024 * 1024)).toStringAsFixed(2),
          );
        });
        return;
      }

      setState(() {
        _pickedFile = file;
        _photoBytes = bytes;
      });
    } catch (e) {
      setState(() => _photoError = t.signupPhotoCannotLoad(e.toString()));
    }
  }

  void _clearPhoto() {
    setState(() {
      _pickedFile = null;
      _photoBytes = null;
      _photoError = null;
    });
  }

  // API attend 1..3
  int _secretQuestionCodeFromIndex(int index) => index + 1;

  Future<void> _submitToApi(SignUpData data) async {
    final t = AppLocalizations.of(context)!;

    final coords = await _getLatLon();
    final latStr = coords.lat.toStringAsFixed(6);
    final lonStr = coords.lon.toStringAsFixed(6);

    final req = http.MultipartRequest('POST', _publicSignupUri())
      ..headers['Accept'] = 'application/json'
      ..headers['X-App-Key'] = _publicAppKey
      ..fields['gender'] = data
          .gender // ✅ "M" / "F"
      ..fields['firstname'] = data.firstName
      ..fields['lastname'] = data.lastName
      ..fields['emailAddress'] = data.email
      ..fields['dateOfBirth'] = DateFormat('yyyy-MM-dd').format(data.birthDate)
      ..fields['genotype'] = data.genotype
      ..fields['longitude'] = lonStr
      ..fields['latitude'] = latStr
      ..fields['password'] = data.password
      ..fields['qSecrete'] = _secretQuestionCodeFromIndex(
        _secretQuestionIndex ?? 0,
      ).toString()
      ..fields['rSecrete'] = data.secretAnswer
      ..fields['consent'] = data.consent ? 'true' : 'false'
      // ✅ NOUVEAU : 1 si coché, 0 sinon
      ..fields['is_info'] = data.acceptAngelmanInfo ? '1' : '0';

    if (data.photoBytes != null && data.photoBytes!.isNotEmpty) {
      final filename = data.photoFilename ?? 'photo.jpg';
      final mime = data.photoMimeType ?? 'image/jpeg';
      req.files.add(
        http.MultipartFile.fromBytes(
          'photo',
          data.photoBytes!,
          filename: filename,
          contentType: http_parser.MediaType.parse(mime),
        ),
      );
    }

    final streamed = await req.send().timeout(const Duration(seconds: 20));
    final resp = await http.Response.fromStream(streamed);

    if (resp.statusCode == 201 || resp.statusCode == 200) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.signupSuccess)));
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }

    if (resp.statusCode == 409) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Center(
            child: Text(
              t.signupEmailAlreadyExistsRedirect,
              textAlign: TextAlign.center,
            ),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }

    String bodyPreview = '';
    try {
      bodyPreview = resp.body;
      if (bodyPreview.length > 200) {
        bodyPreview = '${bodyPreview.substring(0, 200)}…';
      }
    } catch (_) {}

    throw Exception(t.signupApiFailed(resp.statusCode, bodyPreview));
  }

  Future<void> _submit() async {
    final t = AppLocalizations.of(context)!;
    setState(() => _triedSubmit = true);

    if (!(_formKey.currentState?.validate() ?? false)) return;

    // ✅ Sexe obligatoire (clé UI -> code API)
    if (_genderKey == null || _genderKey!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.genderRequired)));
      return;
    }
    final genderApi = _genderApiValue[_genderKey!] ?? 'M';

    if (_birthDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.signupSelectBirthdate)));
      return;
    }
    if (_genotypeKey == null || _genotypeKey!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.signupChooseGenotype)));
      return;
    }
    if (_secretQuestionIndex == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.signupChooseSecretQuestion)));
      return;
    }
    if (_secretAnswerCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.signupEnterSecretAnswer)));
      return;
    }
    if (_photoError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_photoError!)));
      return;
    }
    if (_photoBytes == null || _photoBytes!.isEmpty) {
      setState(() => _photoError = t.signupPhotoRequired);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.signupAddPhotoToContinue)));
      return;
    }
    if (!_consent) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.signupConsentNotGiven)));
      setState(() {});
      return;
    }

    final genotypeApi = _genotypeApiValueFr[_genotypeKey!] ?? 'Clinique';

    final data = SignUpData(
      gender: genderApi, // ✅ "M" / "F"
      firstName: _firstCtrl.text.trim(),
      lastName: _lastCtrl.text.trim(),
      birthDate: _birthDate!,
      genotype: genotypeApi, // ✅ valeur FR envoyée à l'API
      email: _emailCtrl.text.trim(),
      password: _pwdCtrl.text,
      photoBytes: _photoBytes,
      photoFilename: _pickedFile?.name,
      photoMimeType: _inferMime(_pickedFile?.name),
      secretQuestion: _secretQuestionLabel(t, _secretQuestionIndex ?? 0),
      secretAnswer: _secretAnswerCtrl.text.trim(),
      consent: _consent,
      acceptAngelmanInfo: _acceptAngelmanInfo, // ✅ NOUVEAU
    );

    setState(() => _submitting = true);
    try {
      if (widget.onSubmit != null) {
        await widget.onSubmit!(data);
      } else {
        await _submitToApi(data);
      }
    } on TimeoutException {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.timeoutCheckConnection)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.errorWithMessage(e.toString()))));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String? _inferMime(String? filename) {
    final name = (filename ?? '').toLowerCase();
    if (name.endsWith('.png')) return 'image/png';
    if (name.endsWith('.jpg') || name.endsWith('.jpeg')) return 'image/jpeg';
    if (name.endsWith('.webp')) return 'image/webp';
    return null;
  }

  String _genotypeLabel(AppLocalizations t, String key) {
    switch (key) {
      case 'deletion':
        return t.genotypeDeletion;
      case 'mutation':
        return t.genotypeMutation;
      case 'upd':
        return t.genotypeUpd;
      case 'icd':
        return t.genotypeIcd;
      case 'clinical':
        return t.genotypeClinical;
      case 'mosaic':
        return t.genotypeMosaic;
      default:
        return key;
    }
  }

  String _secretQuestionLabel(AppLocalizations t, int index) {
    switch (index) {
      case 0:
        return t.secretQuestion1;
      case 1:
        return t.secretQuestion2;
      case 2:
        return t.secretQuestion3;
      default:
        return t.secretQuestion1;
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewInsets = MediaQuery.of(context).viewInsets;
    final t = AppLocalizations.of(context)!;

    final secretQuestions = <String>[
      t.secretQuestion1,
      t.secretQuestion2,
      t.secretQuestion3,
    ];

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: Text(t.signupTitle), centerTitle: true),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.disabled,
          child: ListView(
            controller: _listCtrl,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(16, 12, 16, 24 + viewInsets.bottom),
            children: [
              // -------- Section 1 --------
              Row(
                children: [
                  Icon(Ionicons.medical, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    t.signupSectionPerson,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ✅ SEXE (AU-DESSUS DU PRÉNOM) — UI localisée, API = "M"/"F"
              DropdownButtonFormField<String>(
                value: _genderKey,
                isExpanded: true,
                borderRadius: BorderRadius.circular(12),
                decoration: InputDecoration(
                  labelText: t.genderLabel,
                  prefixIcon: const Icon(Ionicons.male_female_outline),
                  border: const OutlineInputBorder(),
                ),
                items: const ['male', 'female']
                    .map(
                      (k) => DropdownMenuItem<String>(
                        value: k,
                        child: Text(
                          k == 'male' ? t.genderMale : t.genderFemale,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _genderKey = v),
                validator: (v) =>
                    (v == null || v.isEmpty) ? t.genderRequired : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _firstCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: t.firstNameLabel,
                  prefixIcon: const Icon(Ionicons.person),
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => _requiredText(v, t.firstNameRequired),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _lastCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: t.lastNameLabel,
                  prefixIcon: const Icon(Ionicons.person_outline),
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => _requiredText(v, t.lastNameRequired),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _birthCtrl,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: t.birthdateLabel,
                  prefixIcon: const Icon(Ionicons.calendar),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    tooltip: t.chooseDate,
                    icon: const Icon(Ionicons.calendar_clear),
                    onPressed: _pickBirthDate,
                  ),
                ),
                onTap: _pickBirthDate,
                validator: (_) =>
                    _birthDate == null ? t.birthdateRequired : null,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _genotypeKey,
                isExpanded: true,
                borderRadius: BorderRadius.circular(12),
                decoration: InputDecoration(
                  labelText: t.genotypeLabel,
                  prefixIcon: const Icon(Ionicons.git_branch),
                  border: const OutlineInputBorder(),
                ),
                items: _genotypeApiValueFr.keys
                    .map(
                      (k) => DropdownMenuItem(
                        value: k,
                        child: Text(_genotypeLabel(t, k)),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _genotypeKey = v),
                validator: (v) =>
                    (v == null || v.isEmpty) ? t.genotypeRequired : null,
              ),

              const SizedBox(height: 12),

              Text(
                t.signupPhotoHint,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Ionicons.image_outline),
                    label: Text(t.importPhoto),
                    onPressed: () => _selectPhoto(ImageSource.gallery),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Ionicons.camera_outline),
                    label: Text(t.takePhoto),
                    onPressed: () => _selectPhoto(ImageSource.camera),
                  ),
                  if (_photoBytes != null)
                    OutlinedButton.icon(
                      icon: const Icon(Ionicons.trash_outline),
                      label: Text(t.deletePhoto),
                      onPressed: _clearPhoto,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                        side: BorderSide(color: theme.colorScheme.error),
                      ),
                    ),
                ],
              ),
              if (_photoError != null) ...[
                const SizedBox(height: 8),
                Text(
                  _photoError!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ],
              if (_photoBytes != null) ...[
                const SizedBox(height: 12),
                Center(
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          _photoBytes!,
                          height: 180,
                          width: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Material(
                          color: Colors.black54,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: _clearPhoto,
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(
                                Icons.close,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                if (_pickedFile?.name != null)
                  Center(
                    child: Text(
                      _pickedFile!.name,
                      style: theme.textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],

              const SizedBox(height: 36),

              Row(
                children: [
                  Icon(Ionicons.lock_closed, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    t.signupSectionAuth,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                decoration: InputDecoration(
                  labelText: t.emailLabel,
                  prefixIcon: const Icon(Ionicons.mail),
                  border: const OutlineInputBorder(),
                ),
                validator: _emailError,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _pwdCtrl,
                obscureText: _obscure,
                autofillHints: const [AutofillHints.newPassword],
                decoration: InputDecoration(
                  labelText: t.passwordLabel,
                  prefixIcon: const Icon(Ionicons.key),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    tooltip: _obscure ? t.show : t.hide,
                    icon: Icon(_obscure ? Ionicons.eye : Ionicons.eye_off),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: _passwordError,
              ),
              const SizedBox(height: 8),
              _pwdRule(ok: _passHasMinLen, text: t.signupPwdRuleMin8),
              const SizedBox(height: 4),
              _pwdRule(ok: _passHasUpper, text: t.signupPwdRuleUpper),
              const SizedBox(height: 4),
              _pwdRule(ok: _passHasDigit, text: t.signupPwdRuleDigit),
              const SizedBox(height: 4),
              _pwdRule(ok: _passHasSpec, text: t.signupPwdRuleSpecial),

              const SizedBox(height: 16),

              DropdownButtonFormField<int>(
                value: _secretQuestionIndex,
                isExpanded: true,
                menuMaxHeight: 320,
                borderRadius: BorderRadius.circular(12),
                decoration: InputDecoration(
                  labelText: t.secretQuestionLabel,
                  prefixIcon: const Icon(Ionicons.help_circle_outline),
                  border: const OutlineInputBorder(),
                ),
                items: List.generate(
                  secretQuestions.length,
                  (i) => DropdownMenuItem<int>(
                    value: i,
                    child: Text(
                      secretQuestions[i],
                      maxLines: 2,
                      softWrap: true,
                    ),
                  ),
                ),
                selectedItemBuilder: (ctx) => secretQuestions
                    .map(
                      (q) => Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          q,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  setState(() => _secretQuestionIndex = v);
                  Future.delayed(const Duration(milliseconds: 80), () {
                    if (!mounted) return;
                    final ctx = _secretAnswerKey.currentContext;
                    if (ctx != null) {
                      Scrollable.ensureVisible(
                        ctx,
                        alignment: 0.2,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                      );
                    }
                    FocusScope.of(context).requestFocus(_secretAnswerFocus);
                  });
                },
                validator: (v) => (v == null) ? t.secretQuestionRequired : null,
              ),
              const SizedBox(height: 12),

              Container(
                key: _secretAnswerKey,
                child: TextFormField(
                  focusNode: _secretAnswerFocus,
                  controller: _secretAnswerCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: t.secretAnswerLabel,
                    prefixIcon: const Icon(Ionicons.chatbox_ellipses_outline),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) => _requiredText(v, t.secretAnswerRequired),
                ),
              ),

              const SizedBox(height: 36),

              Row(
                children: [
                  Icon(
                    Ionicons.document_text,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    t.consentTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.6),
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.25),
                ),
                constraints: const BoxConstraints(
                  minHeight: 120,
                  maxHeight: 220,
                ),
                padding: const EdgeInsets.all(12),
                child: SingleChildScrollView(
                  child: Text(t.consentText, textAlign: TextAlign.justify),
                ),
              ),
              const SizedBox(height: 12),

              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _consent,
                onChanged: (v) => setState(() => _consent = v ?? false),
                title: Text(t.consentCheckbox),
                controlAffinity: ListTileControlAffinity.leading,
              ),

              // ✅ NOUVEAU : checkbox opt-in infos Angelman (après le consentement)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _acceptAngelmanInfo,
                onChanged: (v) =>
                    setState(() => _acceptAngelmanInfo = v ?? false),
                title: Text(t.acceptInfoAngelman),
                controlAffinity: ListTileControlAffinity.leading,
              ),

              if (_triedSubmit && !_consent)
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    t.signupConsentNotGiven,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),

              const SizedBox(height: 24),

              SizedBox(
                height: 48,
                child: FilledButton.icon(
                  icon: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Ionicons.checkmark),
                  label: Text(
                    _submitting ? t.signupCreating : t.signupCreateBtn,
                  ),
                  onPressed: _submitting ? null : _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
