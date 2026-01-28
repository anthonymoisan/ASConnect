// lib/main.dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart'; // ✅ NEW
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:ionicons/ionicons.dart';

import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Pages locales
import 'profil/login_page.dart' show LoginPage;
import 'profil/signup_page.dart' show SignUpPage;
import 'profil/forgot_password_page.dart' show ForgotPasswordPage;

import 'mapCartoPeople/mapCartoPeople.dart';
import 'component/app_menu.dart';
import 'profil/privacy_page.dart';
import 'component/contact_page.dart';
import 'profil/edit_profile_page.dart';
import 'component/version.dart';
import 'whatsApp/screens/conversations_page.dart';

import 'tabular/view/tabular_view.dart';

// L10n
import 'l10n/app_localizations.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';

// 🔑 Clé app
const String _publicAppKey = String.fromEnvironment(
  'PUBLIC_APP_KEY',
  defaultValue: '',
);

const apiEnvMapTitleKey = String.fromEnvironment(
  'API_ENVMAPTITLE',
  defaultValue: '',
);

const String _publicBase =
    'https://anthonymoisan.eu.pythonanywhere.com/api/public';

// Local notifications (iOS badge)
final FlutterLocalNotificationsPlugin _localNotifs =
    FlutterLocalNotificationsPlugin();

Future<void> _initIosBadgePermission() async {
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');

  const ios = DarwinInitializationSettings(
    requestAlertPermission: false,
    requestSoundPermission: false,
    requestBadgePermission: true,
  );

  const initSettings = InitializationSettings(android: android, iOS: ios);

  await _localNotifs.initialize(initSettings);

  await _localNotifs
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >()
      ?.requestPermissions(alert: false, sound: false, badge: true);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initIosBadgePermission();
  runApp(const ASConnexion());
}

// ============================================================================
// ✅ 3 modes d'affichage web desktop
// - mobileCard : carte mobile centrée (le reste)  ✅ CONTACT = petit
// - wideCard   : carte large centrée            ✅ HOME = grand
// - fullScreen : plein écran                    ✅ LOGIN = grand
// ============================================================================

enum AppFrameMode { mobileCard, wideCard, fullScreen }

class AppFrameController extends ValueNotifier<AppFrameMode> {
  AppFrameController({AppFrameMode initial = AppFrameMode.mobileCard})
    : super(initial);

  void setMode(AppFrameMode mode) {
    if (value == mode) return;
    value = mode;
  }

  void setMobileCard() => setMode(AppFrameMode.mobileCard);
  void setWideCard() => setMode(AppFrameMode.wideCard);
  void setFullScreen() => setMode(AppFrameMode.fullScreen);
}

class AppFrameScope extends InheritedWidget {
  const AppFrameScope({
    super.key,
    required this.controller,
    required super.child,
  });

  final AppFrameController controller;

  static AppFrameController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppFrameScope>();
    assert(scope != null, 'AppFrameScope not found in widget tree');
    return scope!.controller;
  }

  @override
  bool updateShouldNotify(AppFrameScope oldWidget) =>
      oldWidget.controller != controller;
}

/// Règles:
/// - /login => fullScreen (grand)
/// - /home  => wideCard (grand)
/// - /contact + le reste => mobileCard (petit)
AppFrameMode frameModeForRouteName(String? name) {
  if (name == null || name.isEmpty) return AppFrameMode.mobileCard;
  if (name == '/login') return AppFrameMode.fullScreen;
  if (name == '/home') return AppFrameMode.wideCard;
  // contact explicit pour être sûr
  if (name == '/contact') return AppFrameMode.mobileCard;
  return AppFrameMode.mobileCard;
}

// ============================================================================
// ✅ NavigatorObserver : resync mode sur PUSH/POP/REPLACE
// ✅ MODIF: applique immédiatement quand possible (évite flash)
// ============================================================================

class FrameRouteObserver extends NavigatorObserver {
  FrameRouteObserver(this.controller);

  final AppFrameController controller;

  void _apply(Route<dynamic>? route) {
    if (route is PopupRoute) return;
    if (route is! PageRoute) return;

    final name = route.settings.name;
    final nextMode = frameModeForRouteName(name);
    if (controller.value == nextMode) return;

    final phase = SchedulerBinding.instance.schedulerPhase;
    final canApplyNow =
        phase == SchedulerPhase.idle ||
        phase == SchedulerPhase.postFrameCallbacks;

    if (canApplyNow) {
      controller.setMode(nextMode);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (controller.value != nextMode) controller.setMode(nextMode);
      });
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _apply(route);
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _apply(previousRoute);
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _apply(newRoute);
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}

// ============================================================================
// ✅ Web shell : carte mobile OU wide OU fullScreen selon controller.value
// ============================================================================

class WebResponsiveShell extends StatelessWidget {
  const WebResponsiveShell({
    super.key,
    required this.controller,
    required this.child,
  });

  final AppFrameController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return child;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;

        // Web étroit => plein écran (mobile-like)
        if (!isDesktop) return child;

        return AnimatedBuilder(
          animation: controller,
          builder: (_, __) {
            const bg = BoxDecoration(color: Color(0xFFF2F3F5));

            // FULL SCREEN
            if (controller.value == AppFrameMode.fullScreen) {
              return Container(decoration: bg, child: child);
            }

            // MOBILE CARD
            if (controller.value == AppFrameMode.mobileCard) {
              return Container(
                decoration: bg,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Material(
                        elevation: 10,
                        borderRadius: BorderRadius.circular(20),
                        clipBehavior: Clip.antiAlias,
                        color: Colors.white,
                        child: child,
                      ),
                    ),
                  ),
                ),
              );
            }

            // WIDE CARD
            return Container(
              decoration: bg,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Material(
                        elevation: 6,
                        color: Colors.white,
                        child: child,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ============================================================================
// ✅ Route sans animation (évite flash quand le mode change)
// ============================================================================

class _NoAnimMaterialPageRoute<T> extends MaterialPageRoute<T> {
  _NoAnimMaterialPageRoute({required super.builder, super.settings});

  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Duration get reverseTransitionDuration => Duration.zero;
}

// ============================================================================
// App
// ============================================================================

class ASConnexion extends StatefulWidget {
  const ASConnexion({super.key});

  @override
  State<ASConnexion> createState() => _ASConnexionState();
}

class _ASConnexionState extends State<ASConnexion> with WidgetsBindingObserver {
  int? _personId;
  Locale? _locale;

  final AppFrameController _frameCtrl = AppFrameController(
    initial: AppFrameMode.fullScreen, // ✅ login grand au démarrage
  );

  late final FrameRouteObserver _frameObserver = FrameRouteObserver(_frameCtrl);

  // ✅ Empêche d’envoyer 10 fois le "disconnect" en rafale
  bool _disconnectSent = false;

  // ✅ un navigatorKey évite d’avoir des ctx “dans le vide” pendant les transitions
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // ✅ Force le mode "grand" dès le 1er frame (utile si cache/hot reload)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _applyFrameMode(frameModeForRouteName('/login'));
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ✅ Détecte fermeture / arrière-plan (mobile) + parfois fermeture onglet (web)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Quand on quitte / ferme / met en arrière plan => on notifie "déconnecté"
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _notifyDisconnectedIfNeeded();
    }
  }

  Future<void> _notifyDisconnectedIfNeeded() async {
    final pid = _personId;
    if (pid == null) return;
    if (_disconnectSent) return;
    _disconnectSent = true;

    try {
      final uri = Uri.parse('$_publicBase/auth/connection');
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (_publicAppKey.isNotEmpty) 'X-App-Key': _publicAppKey,
      };

      await http
          .post(
            uri,
            headers: headers,
            body: jsonEncode({'id': pid, 'is_connected': false}),
          )
          .timeout(const Duration(seconds: 12));
    } catch (_) {
      // On ne bloque pas la fermeture
    }
  }

  Future<void> _handleLogin(String email, String pass, int id) async {
    setState(() {
      _personId = id;
      _disconnectSent = false; // ✅ on "réarme" après un nouveau login
    });
  }

  void _handleLogout() {
    setState(() => _personId = null);
    _setLauncherBadge(0);
  }

  void _setLocale(Locale? locale) => setState(() => _locale = locale);

  void _setLauncherBadge(int count) async {
    try {
      final supported = await FlutterAppBadger.isAppBadgeSupported();
      if (!supported) return;

      if (count <= 0) {
        FlutterAppBadger.removeBadge();
      } else {
        FlutterAppBadger.updateBadgeCount(count);
      }
    } catch (_) {}
  }

  // ✅ Applique le mode immédiatement quand possible (évite flash)
  void _applyFrameMode(AppFrameMode nextMode) {
    if (_frameCtrl.value == nextMode) return;

    final phase = SchedulerBinding.instance.schedulerPhase;
    final canApplyNow =
        phase == SchedulerPhase.idle ||
        phase == SchedulerPhase.postFrameCallbacks;

    if (canApplyNow) {
      _frameCtrl.setMode(nextMode);
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_frameCtrl.value != nextMode) _frameCtrl.setMode(nextMode);
    });
  }

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    final name = settings.name ?? '/login';

    // ✅ calcule le mode depuis le nom
    final nextMode = frameModeForRouteName(name);
    final bool modeChanged = _frameCtrl.value != nextMode;

    // ✅ applique le mode tout de suite si possible
    _applyFrameMode(nextMode);

    Widget page;

    switch (name) {
      case '/login':
        page = LoginPage(
          currentLocale: _locale,
          onLocaleChanged: _setLocale,
          onSignUp: () => navigatorKey.currentState?.pushNamed('/signup'),
          onForgotPassword: () =>
              navigatorKey.currentState?.pushNamed('/forgot-password'),
          onLogin: (email, pass, id) async {
            await _handleLogin(email, pass, id);
            if (!mounted) return;

            // ✅ IMPORTANT: on force le mode HOME avant d'afficher la route
            _applyFrameMode(AppFrameMode.wideCard);

            // ✅ pushReplacementNamed via navigatorKey = nom de route OK
            navigatorKey.currentState?.pushReplacementNamed('/home');
          },
        );
        break;

      case '/signup':
        page = const SignUpPage();
        break;

      case '/forgot-password':
        page = const ForgotPasswordPage();
        break;

      case '/home':
        final pid = _personId;
        if (pid == null) {
          page = LoginPage(
            currentLocale: _locale,
            onLocaleChanged: _setLocale,
            onSignUp: () => navigatorKey.currentState?.pushNamed('/signup'),
            onForgotPassword: () =>
                navigatorKey.currentState?.pushNamed('/forgot-password'),
            onLogin: (email, pass, id) async {
              await _handleLogin(email, pass, id);
              if (!mounted) return;

              _applyFrameMode(AppFrameMode.wideCard);
              navigatorKey.currentState?.pushReplacementNamed('/home');
            },
          );
        } else {
          page = HomeScreen(
            personId: pid,
            onLogout: () async {
              // ✅ quand on se logout "proprement", on notifie aussi déconnecté
              await _notifyDisconnectedIfNeeded();
              _handleLogout();
            },
            onBadgeUpdate: _setLauncherBadge,
            currentLocale: _locale,
            onLocaleChanged: _setLocale,
          );
        }
        break;

      case '/contact':
        final pid = _personId;
        if (pid == null) {
          page = LoginPage(
            currentLocale: _locale,
            onLocaleChanged: _setLocale,
            onLogin: (email, pass, id) async {
              await _handleLogin(email, pass, id);
              if (!mounted) return;

              _applyFrameMode(AppFrameMode.wideCard);
              navigatorKey.currentState?.pushReplacementNamed('/home');
            },
          );
        } else {
          // ✅ /contact = petit
          page = ContactPage(personId: pid);
        }
        break;

      case '/version':
        page = const VersionPage();
        break;

      case '/profile/edit':
        final pid = _personId;
        if (pid == null) {
          page = LoginPage(
            currentLocale: _locale,
            onLocaleChanged: _setLocale,
            onLogin: (email, pass, id) async {
              await _handleLogin(email, pass, id);
              if (!mounted) return;

              _applyFrameMode(AppFrameMode.wideCard);
              navigatorKey.currentState?.pushReplacementNamed('/home');
            },
          );
        } else {
          page = EditProfilePage(personId: pid);
        }
        break;

      default:
        page = LoginPage(
          currentLocale: _locale,
          onLocaleChanged: _setLocale,
          onSignUp: () => navigatorKey.currentState?.pushNamed('/signup'),
          onForgotPassword: () =>
              navigatorKey.currentState?.pushNamed('/forgot-password'),
          onLogin: (email, pass, id) async {
            await _handleLogin(email, pass, id);
            if (!mounted) return;

            _applyFrameMode(AppFrameMode.wideCard);
            navigatorKey.currentState?.pushReplacementNamed('/home');
          },
        );
        break;
    }

    final st = RouteSettings(name: name, arguments: settings.arguments);

    if (modeChanged) {
      return _NoAnimMaterialPageRoute(settings: st, builder: (_) => page);
    }
    return MaterialPageRoute(settings: st, builder: (_) => page);
  }

  @override
  Widget build(BuildContext context) {
    return AppFrameScope(
      controller: _frameCtrl,
      child: MaterialApp(
        key: const ValueKey('as-connexion-app'),
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        locale: _locale,

        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: [
          AppLocalizations.delegate,
          LocaleNamesLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],

        onGenerateTitle: (ctx) => AppLocalizations.of(ctx)!.appTitle,
        navigatorObservers: [_frameObserver],

        builder: (ctx, child) {
          if (child == null) return const SizedBox.shrink();
          return WebResponsiveShell(controller: _frameCtrl, child: child);
        },

        initialRoute: '/login',
        onGenerateRoute: _onGenerateRoute,

        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF3F51B5),
        ),
      ),
    );
  }
}

// ============================================================================
// Home (tabs)
// ============================================================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.personId,
    required this.onLogout,
    required this.onBadgeUpdate,
    required this.currentLocale,
    required this.onLocaleChanged,
  });

  final int personId;
  final VoidCallback onLogout;
  final void Function(int count) onBadgeUpdate;

  final Locale? currentLocale;
  final void Function(Locale? locale) onLocaleChanged;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  int _currentIndex = 0;
  int _unreadMessagesTotal = 0;

  Timer? _unreadTimer;
  bool _pollingEnabled = true;
  static const Duration _pollInterval = Duration(seconds: 10);

  static const String? kMapTilerKey = apiEnvMapTitleKey;
  static const bool kAllowOsmInRelease = false;

  late final List<Widget> _tabs = <Widget>[
    MapPeopleByCity(
      currentPersonId: widget.personId,
      mapTilerApiKey: kMapTilerKey,
      allowOsmInRelease: kAllowOsmInRelease,
      osmUserAgent:
          'ASConnexion/1.0 (mobile; contact: contact@angelmananalytics.org)',
    ),
    TabularView(currentPersonId: widget.personId),
    ConversationsPage(personId: widget.personId),
  ];

  void _setIndex(int i) => setState(() => _currentIndex = i);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _refreshUnreadMessagesTotal();
    _startPolling();
  }

  @override
  void dispose() {
    _stopPolling();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _pollingEnabled = true;
      _startPolling();
      _refreshUnreadMessagesTotal();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _pollingEnabled = false;
      _stopPolling();
    }
  }

  void _startPolling() {
    if (!_pollingEnabled) return;
    if (_unreadTimer != null) return;

    _unreadTimer = Timer.periodic(_pollInterval, (_) {
      _refreshUnreadMessagesTotal();
    });
  }

  void _stopPolling() {
    _unreadTimer?.cancel();
    _unreadTimer = null;
  }

  Future<int> _fetchUnreadMessagesTotal(int peopleId) async {
    final uri = Uri.parse('$_publicBase/people/$peopleId/conversationsUnRead');
    final resp = await http.get(uri, headers: {'X-App-Key': _publicAppKey});

    if (resp.statusCode != 200) {
      throw Exception(
        'Erreur unread total (${resp.statusCode}) : ${resp.body}',
      );
    }

    final List<dynamic> list = jsonDecode(resp.body) as List<dynamic>;
    int total = 0;
    for (final item in list) {
      final m = item as Map<String, dynamic>;
      total += (m['unread_count'] as int?) ?? 0;
    }
    return total;
  }

  Future<void> _refreshUnreadMessagesTotal() async {
    try {
      final total = await _fetchUnreadMessagesTotal(widget.personId);
      if (!mounted) return;

      widget.onBadgeUpdate(total);

      if (total == _unreadMessagesTotal) return;
      setState(() => _unreadMessagesTotal = total);
    } catch (_) {}
  }

  Future<void> _logoutAndGoToLogin() async {
    widget.onBadgeUpdate(0);
    widget.onLogout(); // ✅ dans ASConnexionState, on notifie déjà le backend

    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
    }
  }

  Future<void> _confirmLogout() async {
    final t = AppLocalizations.of(context)!;

    final bool? ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(t.logoutTitle),
        content: Text(t.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(t.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(t.confirm),
          ),
        ],
      ),
    );

    if (ok == true) {
      await _logoutAndGoToLogin();
    }
  }

  Future<void> _openPrivacy() async {
    if (!mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        settings: const RouteSettings(name: '/privacy'),
        builder: (_) => PrivacyPage(personId: widget.personId),
      ),
    );
  }

  List<String> _titles(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return <String>[t.tabCommunity, t.tableTabular, t.tabChats];
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final titles = _titles(context);

    return Scaffold(
      key: _scaffoldKey,
      extendBody: true,
      backgroundColor: Colors.white,
      drawer: AppMenu(
        selected: switch (_currentIndex) {
          0 => MenuAction.profil,
          _ => null,
        },
        privacyUrl: 'https://www.example.com/politique-de-confidentialite',
        contactEmail: 'contact@fastfrance.org',
        appVersion: '0.9',
        currentLocale: widget.currentLocale,
        onLocaleChanged: widget.onLocaleChanged,
        onSelected: (action) async {
          switch (action) {
            case MenuAction.profil:
              if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
                Navigator.of(context).pop();
              }
              final updated = await Navigator.of(
                context,
              ).pushNamed('/profile/edit', arguments: const {});
              _setIndex(0);
              if (updated == true && mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(t.profileUpdated)));
              }
              break;

            case MenuAction.contact:
              if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
                Navigator.of(context).pop();
              }
              if (mounted) Navigator.of(context).pushNamed('/contact');
              break;

            case MenuAction.privacy:
              if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
                Navigator.of(context).pop();
              }
              await _openPrivacy();
              break;

            case MenuAction.logout:
              await _confirmLogout();
              break;

            case MenuAction.version:
              if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
                Navigator.of(context).pop();
              }
              if (mounted) Navigator.of(context).pushNamed('/version');
              break;
          }
        },
      ),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        centerTitle: true,
        leading: IconButton(
          tooltip: t.menu,
          icon: const Icon(Ionicons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(
          titles[_currentIndex],
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
      ),
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: SafeArea(
        child: BottomAppBar(
          color: Colors.transparent,
          elevation: 0,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 210),
              child: Container(
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    width: 0.05,
                    color: const Color.fromARGB(255, 24, 83, 79),
                  ),
                  color: Colors.white.withOpacity(0.92),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SizedBox(
                  height: 50,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _NavIcon(
                          icon: Ionicons.people,
                          selected: _currentIndex == 0,
                          onTap: () => _setIndex(0),
                        ),
                        const SizedBox(width: 28),
                        _NavIcon(
                          icon: Ionicons.grid_outline,
                          selected: _currentIndex == 1,
                          onTap: () => _setIndex(1),
                        ),
                        const SizedBox(width: 28),
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            _NavIcon(
                              icon: Ionicons.chatbubble,
                              selected: _currentIndex == 2,
                              onTap: () {
                                _setIndex(2);
                                _refreshUnreadMessagesTotal();
                              },
                            ),
                            _Badge(count: _unreadMessagesTotal),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const selColor = Color.fromARGB(255, 206, 106, 107);
    const baseColor = Color.fromARGB(255, 33, 46, 83);

    return InkResponse(
      onTap: onTap,
      radius: 22,
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Icon(icon, size: 24, color: selected ? selColor : baseColor),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final int count;
  const _Badge({required this.count});

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    final label = count > 99 ? '99+' : '$count';

    return Positioned(
      right: -2,
      top: -2,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.green.shade600,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white, width: 2),
        ),
        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
