import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // Request all permissions the app needs
  static Future<void> requestAppPermissions() async {
    await [
      Permission.phone,
      Permission.location,
    ].request();
  }

  // Check if phone permission is granted
  static Future<bool> hasPhonePermission() async {
    return await Permission.phone.isGranted;
  }

  // Check if location permission is granted
  static Future<bool> hasLocationPermission() async {
    return await Permission.location.isGranted;
  }

  // Open app settings if user denied permanently
  static Future<void> openSettings() async {
    await openAppSettings();
  }
}