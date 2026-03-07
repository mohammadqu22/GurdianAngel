import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/disclaimer_screen.dart';
import 'services/permission_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PermissionService.requestAppPermissions();
  
  // Check if disclaimer was already accepted
  final prefs = await SharedPreferences.getInstance();
  final disclaimerAccepted = prefs.getBool('disclaimer_accepted') ?? false;
  
  runApp(GuardianAngelApp(showDisclaimer: !disclaimerAccepted));
}

class GuardianAngelApp extends StatelessWidget {
  final bool showDisclaimer;
  
  const GuardianAngelApp({
    super.key,
    required this.showDisclaimer,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guardian Angel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: showDisclaimer ? const DisclaimerScreen() : const HomeScreen(),
    );
  }
}