import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/disclaimer_screen.dart';
import 'services/permission_service.dart';
import 'services/database_service.dart';
import 'core/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Launch the UI immediately — no awaits before runApp!
  runApp(const GuardianAngelApp());
}

class GuardianAngelApp extends StatefulWidget {
  const GuardianAngelApp({super.key});

  @override
  State<GuardianAngelApp> createState() => _GuardianAngelAppState();
}

class _GuardianAngelAppState extends State<GuardianAngelApp> {
  bool _loading = true;
  bool _showDisclaimer = true;
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await DatabaseService.database;
      final prefs = await SharedPreferences.getInstance();
      final accepted = prefs.getBool('disclaimer_accepted') ?? false;
      final themePref = prefs.getString('theme_mode') ?? 'system';
      if (mounted) {
        setState(() {
          _showDisclaimer = !accepted;
          _themeMode = _themeModeFromString(themePref);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
    PermissionService.requestAppPermissions();
  }

  ThemeMode _themeModeFromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  void _onThemeModeChanged(ThemeMode mode) {
    setState(() => _themeMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guardian Angel',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: _themeMode,
      home: _loading
          ? const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            )
          : _showDisclaimer
              ? DisclaimerScreen(onThemeModeChanged: _onThemeModeChanged)
              : HomeScreen(onThemeModeChanged: _onThemeModeChanged),
    );
  }
}