import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/database_service.dart';
import '../services/location_service.dart';
import '../core/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.onThemeModeChanged});

  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'English';
  bool _ttsEnabled = true;
  ThemeMode _themeMode = ThemeMode.system;
  Map<String, dynamic>? _emergencyContact;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadEmergencyContact();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _selectedLanguage = prefs.getString('language') ?? 'English';
      _ttsEnabled = prefs.getBool('tts_enabled') ?? true;
      _themeMode = _themeModeFromString(prefs.getString('theme_mode') ?? 'system');
    });
  }

  ThemeMode _themeModeFromString(String value) {
    switch (value) {
      case 'light': return ThemeMode.light;
      case 'dark': return ThemeMode.dark;
      default: return ThemeMode.system;
    }
  }

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light: return 'Light';
      case ThemeMode.dark: return 'Dark';
      default: return 'System Default';
    }
  }

  Future<void> _saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    final String value;
    switch (mode) {
      case ThemeMode.light: value = 'light'; break;
      case ThemeMode.dark: value = 'dark'; break;
      default: value = 'system';
    }
    await prefs.setString('theme_mode', value);
    if (!mounted) return;
    setState(() => _themeMode = mode);
    widget.onThemeModeChanged(mode);
  }

  Future<void> _loadEmergencyContact() async {
    final contact = await DatabaseService.getEmergencyContact();
    if (!mounted) return;
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
      builder: (context) {
        final dialogCs = Theme.of(context).colorScheme;
        return Dialog(
          backgroundColor: dialogCs.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.contact_phone, color: dialogCs.primary),
                    const SizedBox(width: 10),
                    Text(
                      'Emergency Contact',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person, color: dialogCs.outline),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone, color: dialogCs.outline),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_emergencyContact != null)
                      TextButton(
                        onPressed: () async {
                          final nav = Navigator.of(context);
                          final messenger = ScaffoldMessenger.of(context);
                          await DatabaseService.deleteEmergencyContact();
                          await _loadEmergencyContact();
                          if (mounted) {
                            nav.pop();
                            messenger.showSnackBar(
                              const SnackBar(content: Text('Contact deleted')),
                            );
                          }
                        },
                        child: Text('Delete',
                            style: TextStyle(color: dialogCs.error)),
                      ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: const Alignment(-0.97, -0.26),
                          end: const Alignment(0.97, 0.26),
                          colors: [dialogCs.primary, dialogCs.primaryContainer],
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          onTap: () async {
                            final name = nameController.text.trim();
                            final phone = phoneController.text.trim();
                            if (name.isEmpty || phone.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Please fill in both fields')),
                              );
                              return;
                            }
                            final nav = Navigator.of(context);
                            final messenger = ScaffoldMessenger.of(context);
                            await DatabaseService.saveEmergencyContact(name, phone);
                            await _loadEmergencyContact();
                            if (mounted) {
                              nav.pop();
                              messenger.showSnackBar(
                                SnackBar(
                                    content: Text('$name saved as emergency contact')),
                              );
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            child: Text(
                              'SAVE',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    color: dialogCs.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
      builder: (context) {
        final dialogCs = Theme.of(context).colorScheme;
        return Dialog(
          backgroundColor: dialogCs.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                CircularProgressIndicator(color: dialogCs.primary),
                const SizedBox(width: 16),
                const Text('Fetching location...'),
              ],
            ),
          ),
        );
      },
    );

    final position = await LocationService.getCurrentLocation();
    if (mounted) Navigator.pop(context);

    if (position == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Could not get location. Check GPS settings.')),
        );
      }
      return;
    }

    final mapsLink = LocationService.getMapsLink(position);
    final formatted = LocationService.formatLocation(position);

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) {
          final dialogCs = Theme.of(context).colorScheme;
          final theme = Theme.of(context);
          return Dialog(
            backgroundColor: dialogCs.surfaceContainerLowest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, color: dialogCs.primary),
                      const SizedBox(width: 10),
                      Text(
                        'My Location',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Share this link with someone to show your location:',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: dialogCs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: dialogCs.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Text(mapsLink,
                        style: theme.textTheme.bodyMedium),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Coordinates: $formatted',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: dialogCs.outline,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: const Alignment(-0.97, -0.26),
                            end: const Alignment(0.97, 0.26),
                            colors: [dialogCs.primary, dialogCs.primaryContainer],
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            onTap: () {
                              final messenger = ScaffoldMessenger.of(context);
                              Clipboard.setData(ClipboardData(text: mapsLink));
                              Navigator.pop(context);
                              messenger.showSnackBar(
                                const SnackBar(
                                    content: Text('Location link copied! 📋')),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.copy,
                                      size: 18, color: dialogCs.onPrimary),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Copy Link',
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: dialogCs.onPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Subtitle ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Configure your life-saving assistant.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // ── Preferences Section ──
            _buildSectionHeader('Preferences'),
            const SizedBox(height: 12),

            _buildSettingCard(
              icon: Icons.language,
              iconColor: cs.tertiary,
              title: 'Language',
              subtitle: _selectedLanguage,
              onTap: () => _showLanguageDialog(),
            ),

            _buildSettingCard(
              icon: Icons.brightness_6_outlined,
              iconColor: cs.tertiary,
              title: 'App Theme',
              subtitle: _themeModeLabel(_themeMode),
              onTap: () => _showThemeDialog(),
            ),

            _buildSwitchCard(
              icon: Icons.record_voice_over,
              iconColor: cs.tertiary,
              title: 'Voice Guidance',
              subtitle: 'TTS Audio Instructions',
              value: _ttsEnabled,
              onChanged: (value) => _saveTTS(value),
            ),

            const SizedBox(height: 32),

            // ── Emergency Contact Section ──
            _buildSectionHeader('Emergency Contact'),
            const SizedBox(height: 12),

            _emergencyContact != null
                ? Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 6),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: cs.primary.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Icon(Icons.contact_phone,
                              color: cs.primary, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _emergencyContact!['name'],
                                style: theme.textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _emergencyContact!['phone_number'],
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.phone, color: cs.tertiary),
                          onPressed: _callEmergencyContact,
                          tooltip: 'Call contact',
                        ),
                        IconButton(
                          icon: Icon(Icons.edit, color: cs.outline),
                          onPressed: _showEmergencyContactDialog,
                          tooltip: 'Edit contact',
                        ),
                      ],
                    ),
                  )
                : _buildSettingCard(
                    icon: Icons.person_add,
                    iconColor: cs.primary,
                    title: 'Add Emergency Contact',
                    subtitle: 'Save a trusted person to call in emergencies',
                    onTap: _showEmergencyContactDialog,
                  ),

            const SizedBox(height: 8),

            // ── Location Tools ──
            _buildSectionHeader('Location Tools'),
            const SizedBox(height: 12),

            _buildSettingCard(
              icon: Icons.location_on,
              iconColor: cs.tertiary,
              title: 'Share My Location',
              subtitle: 'Live updates with emergency services',
              onTap: _showLocationDialog,
            ),

            const SizedBox(height: 32),

            // ── Information Section ──
            _buildSectionHeader('Information'),
            const SizedBox(height: 12),

            _buildSettingCard(
              icon: Icons.verified_user,
              iconColor: cs.secondary,
              title: 'Medical Sources',
              subtitle: 'View our verified sources',
              onTap: () => _showMedicalSourcesDialog(),
            ),

            _buildSettingCard(
              icon: Icons.info_outline,
              iconColor: cs.outline,
              title: 'About Guardian Angel',
              subtitle: 'App information & version',
              onTap: () => _showAboutDialog(),
            ),

            const SizedBox(height: 32),

            // ── Disclaimer Notice ──
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Medical Disclaimer',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'This application is an educational and supportive tool. It does not replace professional medical advice, diagnosis, or treatment. Always seek the advice of your physician or other qualified health provider with any questions regarding a medical condition. In case of a life-threatening emergency, call your local emergency services immediately.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: cs.outline,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w600,
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: cs.outline, size: 22),
          ],
        ),
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        secondary: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeThumbColor: cs.primary,
        activeTrackColor: cs.primaryContainer,
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final dialogCs = Theme.of(context).colorScheme;
        return Dialog(
          backgroundColor: dialogCs.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'App Theme',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _buildThemeOption(ThemeMode.system, 'System Default', Icons.brightness_auto),
                _buildThemeOption(ThemeMode.light, 'Light', Icons.light_mode_outlined),
                _buildThemeOption(ThemeMode.dark, 'Dark', Icons.dark_mode_outlined),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(ThemeMode mode, String label, IconData icon) {
    final cs = Theme.of(context).colorScheme;
    final isSelected = _themeMode == mode;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: Icon(icon, color: isSelected ? cs.primary : cs.outline),
      title: Text(label, style: Theme.of(context).textTheme.titleMedium),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: cs.primary)
          : null,
      onTap: () {
        _saveThemeMode(mode);
        Navigator.pop(context);
      },
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final dialogCs = Theme.of(context).colorScheme;
        return Dialog(
          backgroundColor: dialogCs.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Select Language',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _buildLanguageOption('English', '🇬🇧'),
                _buildLanguageOption('Hebrew', '🇮🇱'),
                _buildLanguageOption('Arabic', '🇸🇦'),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(String language, String flag) {
    final cs = Theme.of(context).colorScheme;
    final isSelected = _selectedLanguage == language;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(
        language,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: cs.primary)
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
      builder: (context) {
        final dialogCs = Theme.of(context).colorScheme;
        final theme = Theme.of(context);
        return Dialog(
          backgroundColor: dialogCs.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.verified_user, color: dialogCs.primary),
                    const SizedBox(width: 10),
                    Text(
                      'Medical Sources',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'All emergency procedures are based on verified sources:',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSourceItem('American Red Cross', 'First Aid Guidelines'),
                _buildSourceItem('World Health Organization', 'Emergency Care'),
                _buildSourceItem('American Heart Association', 'CPR Standards'),
                _buildSourceItem('Magen David Adom', 'Israeli Protocols'),
                const SizedBox(height: 16),
                Text(
                  'Last verified: January 2026',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: dialogCs.outline,
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSourceItem(String title, String subtitle) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: cs.tertiary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    )),
                Text(subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontSize: 13,
                    )),
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
      builder: (context) {
        final dialogCs = Theme.of(context).colorScheme;
        final theme = Theme.of(context);
        return Dialog(
          backgroundColor: dialogCs.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.medical_services, color: dialogCs.primary),
                    const SizedBox(width: 10),
                    Text(
                      'About Guardian Angel',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Guardian Angel',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: dialogCs.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text('Version 1.0.0',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: dialogCs.outline,
                    )),
                const SizedBox(height: 16),
                Text(
                  'An interactive emergency first-aid guide providing step-by-step guidance during medical emergencies.',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                Text('Developed by:',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    )),
                const SizedBox(height: 6),
                Text('Mohammad Quttaineh', style: theme.textTheme.bodyLarge),
                Text('Amru Alyan', style: theme.textTheme.bodyLarge),
                const SizedBox(height: 16),
                Text(
                  '© 2026 Guardian Angel\nAzrieli College of Engineering',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: dialogCs.outline,
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
