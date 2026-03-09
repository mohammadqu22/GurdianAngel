import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/database_service.dart';
import '../services/location_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'English';
  bool _ttsEnabled = true;
  Map<String, dynamic>? _emergencyContact;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadEmergencyContact();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('language') ?? 'English';
      _ttsEnabled = prefs.getBool('tts_enabled') ?? true;
    });
  }

  Future<void> _loadEmergencyContact() async {
    final contact = await DatabaseService.getEmergencyContact();
    setState(() {
      _emergencyContact = contact;
    });
  }

  Future<void> _saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
    setState(() {
      _selectedLanguage = language;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Language changed to $language'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _saveTTS(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tts_enabled', enabled);
    setState(() {
      _ttsEnabled = enabled;
    });
  }

  void _showEmergencyContactDialog() {
    final nameController = TextEditingController(
      text: _emergencyContact?['name'] ?? '',
    );
    final phoneController = TextEditingController(
      text: _emergencyContact?['phone_number'] ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.contact_phone, color: Color(0xFFE53935)),
            SizedBox(width: 8),
            Text('Emergency Contact'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          if (_emergencyContact != null)
            TextButton(
              onPressed: () async {
                await DatabaseService.deleteEmergencyContact();
                await _loadEmergencyContact();
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Contact deleted')),
                  );
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final phone = phoneController.text.trim();
              if (name.isEmpty || phone.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill in both fields')),
                );
                return;
              }
              await DatabaseService.saveEmergencyContact(name, phone);
              await _loadEmergencyContact();
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$name saved as emergency contact')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _callEmergencyContact() async {
    if (_emergencyContact == null) return;
    final phone = _emergencyContact!['phone_number'];
    final Uri callUri = Uri(scheme: 'tel', path: phone);
    try {
      await launchUrl(callUri);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open dialer')),
        );
      }
    }
  }

  Future<void> _showLocationDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(color: Color(0xFFE53935)),
            SizedBox(width: 16),
            Text('Fetching location...'),
          ],
        ),
      ),
    );

    final position = await LocationService.getCurrentLocation();
    if (mounted) Navigator.pop(context);

    if (position == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Could not get location. Check GPS settings.')),
        );
      }
      return;
    }

    final mapsLink = LocationService.getMapsLink(position);
    final formatted = LocationService.formatLocation(position);

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.location_on, color: Color(0xFFE53935)),
              SizedBox(width: 8),
              Text('My Location'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Share this link with someone to show your location:',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(mapsLink,
                    style: const TextStyle(fontSize: 13)),
              ),
              const SizedBox(height: 8),
              Text(
                'Coordinates: $formatted',
                style:
                    TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: mapsLink));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Location link copied! 📋')),
                );
              },
              icon: const Icon(Icons.copy, size: 18),
              label: const Text('Copy Link'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFE53935),
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Preferences Section
            _buildSectionHeader('Preferences'),
            const SizedBox(height: 12),

            _buildSettingCard(
              icon: Icons.language,
              iconColor: Colors.blue,
              title: 'Language',
              subtitle: _selectedLanguage,
              onTap: () => _showLanguageDialog(),
            ),

            _buildSwitchCard(
              icon: Icons.record_voice_over,
              iconColor: Colors.green,
              title: 'Voice Guidance (TTS)',
              subtitle: 'Read instructions aloud',
              value: _ttsEnabled,
              onChanged: (value) => _saveTTS(value),
            ),

            const SizedBox(height: 32),

            // Emergency Contact Section
            _buildSectionHeader('Emergency Contact'),
            const SizedBox(height: 12),

            _emergencyContact != null
                ? Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side:
                          BorderSide(color: Colors.grey[200]!, width: 1),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.contact_phone,
                            color: Colors.red, size: 24),
                      ),
                      title: Text(
                        _emergencyContact!['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle:
                          Text(_emergencyContact!['phone_number']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.phone,
                                color: Colors.green),
                            onPressed: _callEmergencyContact,
                            tooltip: 'Call contact',
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit,
                                color: Colors.grey),
                            onPressed: _showEmergencyContactDialog,
                            tooltip: 'Edit contact',
                          ),
                        ],
                      ),
                    ),
                  )
                : _buildSettingCard(
                    icon: Icons.person_add,
                    iconColor: Colors.red,
                    title: 'Add Emergency Contact',
                    subtitle:
                        'Save a trusted person to call in emergencies',
                    onTap: _showEmergencyContactDialog,
                  ),

            const SizedBox(height: 8),

            // Share Location Card (under Emergency Contact)
            _buildSettingCard(
              icon: Icons.location_on,
              iconColor: Colors.teal,
              title: 'Share My Location',
              subtitle:
                  'Copy your GPS location to share in an emergency',
              onTap: _showLocationDialog,
            ),

            const SizedBox(height: 32),

            // Information Section
            _buildSectionHeader('Information'),
            const SizedBox(height: 12),

            _buildSettingCard(
              icon: Icons.verified_user,
              iconColor: Colors.orange,
              title: 'Medical Sources',
              subtitle: 'View our verified sources',
              onTap: () => _showMedicalSourcesDialog(),
            ),

            _buildSettingCard(
              icon: Icons.info_outline,
              iconColor: Colors.purple,
              title: 'About Guardian Angel',
              subtitle: 'App information & version',
              onTap: () => _showAboutDialog(),
            ),

            const SizedBox(height: 32),

            // Disclaimer Notice
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: Colors.orange[200]!, width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.orange[700], size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This app provides guidance only and does not replace professional medical care.',
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey[800]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(
          title,
          style:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
      ),
    );
  }

  Widget _buildSwitchCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: SwitchListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(
          title,
          style:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFFE53935),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('English', '🇬🇧'),
            _buildLanguageOption('Hebrew', '🇮🇱'),
            _buildLanguageOption('Arabic', '🇸🇦'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String language, String flag) {
    final isSelected = _selectedLanguage == language;
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(language),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Color(0xFFE53935))
          : null,
      onTap: () {
        _saveLanguage(language);
        Navigator.pop(context);
      },
    );
  }

  void _showMedicalSourcesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.verified_user, color: Color(0xFFE53935)),
            SizedBox(width: 8),
            Text('Medical Sources'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'All emergency procedures are based on verified sources:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildSourceItem('American Red Cross', 'First Aid Guidelines'),
              _buildSourceItem('World Health Organization', 'Emergency Care'),
              _buildSourceItem('American Heart Association', 'CPR Standards'),
              _buildSourceItem('Magen David Adom', 'Israeli Protocols'),
              const SizedBox(height: 16),
              Text(
                'Last verified: January 2026',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceItem(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        const TextStyle(fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.medical_services, color: Color(0xFFE53935)),
            SizedBox(width: 8),
            Text('About Guardian Angel'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Guardian Angel',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE53935),
              ),
            ),
            const SizedBox(height: 8),
            Text('Version 1.0.0',
                style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            const Text(
              'An interactive emergency first-aid guide providing step-by-step guidance during medical emergencies.',
            ),
            const SizedBox(height: 16),
            const Text('Developed by:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Mohammad Quttaineh'),
            const Text('Amru Alyan'),
            const SizedBox(height: 16),
            Text(
              '© 2026 Guardian Angel\nAzrieli College of Engineering',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}