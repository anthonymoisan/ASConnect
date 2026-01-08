// lib/main.dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ionicons/ionicons.dart';
import 'package:http/http.dart' as http;

// ✅ Badge icône app (launcher)
import 'package:flutter_app_badger/flutter_app_badger.dart';

// ✅ Permission badge iOS (sans Firebase)
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Pages locales
import 'profil/login_page.dart' show LoginPage;
import 'profil/signup_page.dart' show SignUpPage;
import 'mapCartoPeople/mapCartoPeople.dart';
import 'component/app_menu.dart';
import 'profil/privacy_page.dart';
import 'component/contact_page.dart';
import 'profil/edit_profile_page.dart';
import 'component/version.dart';
import 'whatsApp/screens/conversations_page.dart';

// ✅ AppLocalizations (généré via ARB)
import 'l10n/app_localizations.dart';

// 🔑 Clé d'application publique — valable pour tous les endpoints /api/public/*
const String _publicAppKey = String.fromEnvironment(
  'PUBLIC_APP_KEY',
  defaultValue: '',
);

const apiEnvMapTitleKey = String.fromEnvironment(
  'API_ENVMAPTITLE',
  defaultValue: '',
);

// Base API publique
const String _publicBase =
    'https://anthonymoisan.pythonanywhere.com/api/public';

// ✅ Local notifications (uniquement pour demander permission badge sur iOS)
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
// ✅ Frame controller + scope (permet aux pages d'être "wide" ou "mobile frame")
// value == true  => mobile frame
// value == false => wide
// ============================================================================

class AppFrameController extends ValueNotifier<bool> {
  AppFrameController({bool initialMobileFrame = true})
    : super(initialMobileFrame);

  void setMobileFrame(bool enabled) {
    if (value == enabled) return;
    value = enabled;
  }
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

// ============================================================================
// ✅ NavigatorObserver : frame dépend de la route courante
// - Wide : /home, /privacy
// - Mobile : le reste
// ============================================================================

class FrameRouteObserver extends NavigatorObserver {
  FrameRouteObserver(this.controller);

  final AppFrameController controller;

  void _syncFrameFor(Route<dynamic>? route) {
    // 1) Ignore overlays: bottom sheets, dialogs, etc.
    if (route is PopupRoute) return;

    // 2) On ne réagit que sur des vraies pages
    if (route is! PageRoute) return;

    // 3) Il nous faut un nom de route
    final name = route.settings.name;
    if (name == null) return;

    // 4) Wide uniquement pour /home (Map+Chat) par exemple
    final wide = (name == '/home');

    // Ici controller.value = true => mobile frame (chez toi)
    controller.setMobileFrame(!wide);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _syncFrameFor(route);
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // après pop, on revient à la route précédente
    _syncFrameFor(previousRoute);
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _syncFrameFor(newRoute);
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}

// ============================================================================
// ✅ Web shell : mobile frame OU wide selon controller.value
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

        // Web étroit => plein écran
        if (!isDesktop) return child;

        return AnimatedBuilder(
          animation: controller,
          builder: (_, __) {
            final useMobileFrame = controller.value; // true => frame mobile
            const bg = BoxDecoration(color: Color(0xFFF2F3F5));

            if (useMobileFrame) {
              // ✅ mobile frame centré
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

            // ✅ wide (home+privacy) mais avec max
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
// App
// ============================================================================

class ASConnexion extends StatefulWidget {
  const ASConnexion({super.key});

  @override
  State<ASConnexion> createState() => _ASConnexionState();
}

class _ASConnexionState extends State<ASConnexion> {
  int? _personId;

  /// ✅ Locale sélectionnée par l’utilisateur.
  /// - null = "Système"
  Locale? _locale;

  // ✅ contrôleur frame (par défaut : mobile frame sur web desktop)
  final AppFrameController _frameCtrl = AppFrameController(
    initialMobileFrame: true,
  );

  late final FrameRouteObserver _frameObserver = FrameRouteObserver(_frameCtrl);

  Future<void> _handleLogin(String email, String pass, int id) async {
    setState(() => _personId = id);
  }

  void _handleLogout() {
    setState(() => _personId = null);
    _setLauncherBadge(0);
  }

  void _setLocale(Locale? locale) {
    setState(() => _locale = locale);
  }

  // ✅ helper badge launcher
  void _setLauncherBadge(int count) async {
    try {
      final supported = await FlutterAppBadger.isAppBadgeSupported();
      if (!supported) return;

      if (count <= 0) {
        FlutterAppBadger.removeBadge();
      } else {
        FlutterAppBadger.updateBadgeCount(count);
      }
    } catch (_) {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppFrameScope(
      controller: _frameCtrl,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,

        // ✅ Multi-langue
        locale: _locale, // null = système
        supportedLocales: const [Locale('fr'), Locale('en'), Locale('es')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],

        onGenerateTitle: (ctx) => AppLocalizations.of(ctx)!.appTitle,

        navigatorObservers: [_frameObserver],

        // ✅ wrap global du rendu web
        builder: (ctx, child) {
          if (child == null) return const SizedBox.shrink();
          return WebResponsiveShell(controller: _frameCtrl, child: child);
        },

        initialRoute: '/login',

        // ====== ROUTES ======
        routes: <String, WidgetBuilder>{
          '/login': (ctx) => LoginPage(
            currentLocale: _locale,
            onLocaleChanged: _setLocale,
            onLogin: (email, pass, id) async {
              await _handleLogin(email, pass, id);
              if (ctx.mounted) {
                Navigator.of(ctx).pushReplacementNamed('/home');
              }
            },
          ),

          '/signup': (_) => const SignUpPage(),

          '/home': (ctx) {
            final pid = _personId;
            if (pid == null) {
              return LoginPage(
                currentLocale: _locale,
                onLocaleChanged: _setLocale,
                onLogin: (email, pass, id) async {
                  await _handleLogin(email, pass, id);
                  if (ctx.mounted) {
                    Navigator.of(ctx).pushReplacementNamed('/home');
                  }
                },
              );
            }
            return HomeScreen(
              personId: pid,
              onLogout: _handleLogout,
              onBadgeUpdate: _setLauncherBadge,
              currentLocale: _locale,
              onLocaleChanged: _setLocale,
            );
          },

          '/contact': (_) => const ContactPage(),
          '/version': (_) => const VersionPage(),

          '/profile/edit': (ctx) {
            final pid = _personId;
            if (pid == null) {
              return LoginPage(
                currentLocale: _locale,
                onLocaleChanged: _setLocale,
                onLogin: (email, pass, id) async {
                  await _handleLogin(email, pass, id);
                  if (ctx.mounted) {
                    Navigator.of(ctx).pushReplacementNamed('/home');
                  }
                },
              );
            }
            return EditProfilePage(personId: pid);
          },
        },

        // ====== THEME ======
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF3F51B5),
        ),
      ),
    );
  }
}

// ============================================================================
// Home (onglets avec IndexedStack)
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

  // ✅ pour le sélecteur dans AppMenu
  final Locale? currentLocale;
  final void Function(Locale? locale) onLocaleChanged;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  /// 0 = Community (MapPeopleByCity)
  /// 1 = Chats
  int _currentIndex = 0;

  int _unreadMessagesTotal = 0;

  Timer? _unreadTimer;
  bool _pollingEnabled = true;
  static const Duration _pollInterval = Duration(seconds: 10);

  // --- CONFIG MAPS ---
  static const String? kMapTilerKey = apiEnvMapTitleKey;
  static const bool kAllowOsmInRelease = false;

  late final List<Widget> _tabs = <Widget>[
    MapPeopleByCity(
      currentPersonId: widget.personId,
      mapTilerApiKey: kMapTilerKey,
      allowOsmInRelease: kAllowOsmInRelease,
      osmUserAgent: 'ASConnexion/1.0 (mobile; contact: contact@fastfrance.org)',
    ),
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
    widget.onLogout();

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

    // ✅ IMPORTANT: on donne un name à la route pour que l'observer la détecte (wide)
    await Navigator.of(context).push(
      MaterialPageRoute(
        settings: const RouteSettings(name: '/privacy'),
        builder: (_) => PrivacyPage(personId: widget.personId),
      ),
    );
  }

  List<String> _titles(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return <String>[t.tabCommunity, t.tabChats];
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
              ).pushNamed('/profile/edit');
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
              constraints: const BoxConstraints(maxWidth: 150),
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
                        const SizedBox(width: 32),
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            _NavIcon(
                              icon: Ionicons.chatbubble,
                              selected: _currentIndex == 1,
                              onTap: () {
                                _setIndex(1);
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

// ============================================================================
// Petit bouton d’onglet stylé
// ============================================================================

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

// ============================================================================
// Badge WhatsApp-like (vert)
// ============================================================================

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
