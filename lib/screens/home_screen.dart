import 'package:flutter/material.dart';
import 'step_screen.dart';
import 'settings_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onThemeModeChanged});

  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // All emergencies list (accent colors are category constants, not theme tokens)
  final List<Map<String, dynamic>> _allEmergencies = [
    {'id': 'choking', 'title': 'Choking', 'icon': Icons.air, 'color': AppColors.chokingBlue},
    {'id': 'choking_infant', 'title': 'Choking (Infant)', 'icon': Icons.baby_changing_station, 'color': AppColors.chokingBlue},
    {'id': 'cpr', 'title': 'CPR', 'icon': Icons.favorite, 'color': AppColors.cprRed},
    {'id': 'cpr_infant', 'title': 'CPR (Infant)', 'icon': Icons.monitor_heart, 'color': AppColors.cprRed},
    {'id': 'burns', 'title': 'Burns', 'icon': Icons.local_fire_department, 'color': AppColors.burnOrange},
    {'id': 'bleeding', 'title': 'Bleeding', 'icon': Icons.water_drop, 'color': AppColors.bleedingCrimson},
    {'id': 'fractures', 'title': 'Fractures', 'icon': Icons.healing, 'color': AppColors.fracturePurple},
    {'id': 'seizures', 'title': 'Seizures', 'icon': Icons.warning_amber_rounded, 'color': AppColors.seizureAmber},
  ];

  List<Map<String, dynamic>> get _filteredEmergencies {
    if (_searchQuery.isEmpty) return _allEmergencies;
    return _allEmergencies
        .where((e) => (e['title'] as String)
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Guardian Angel',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Emergency Response',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  // Settings icon — tonal surface circle
                  IconButton(
                    tooltip: 'Settings',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingsScreen(
                            onThemeModeChanged: widget.onThemeModeChanged,
                          ),
                        ),
                      );
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: cs.surfaceContainerLow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      fixedSize: const Size(48, 48),
                    ),
                    icon: Icon(
                      Icons.settings_outlined,
                      color: cs.onSurface,
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Section title ──
              Text(
                'Select Emergency Type',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              // ── Search Bar (filled, no border — "No-Line" rule) ──
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search emergency...',
                  prefixIcon: Icon(Icons.search, color: cs.outline),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: cs.outline),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 20),

              // ── Grid or "No results" ──
              Expanded(
                child: _filteredEmergencies.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 64, color: cs.outline),
                            const SizedBox(height: 12),
                            Text(
                              'No emergency found',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: cs.outline,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        children: _filteredEmergencies
                            .map((e) => _buildEmergencyCard(
                                  context,
                                  id: e['id'] as String,
                                  title: e['title'] as String,
                                  icon: e['icon'] as IconData,
                                  color: e['color'] as Color,
                                ))
                            .toList(),
                      ),
              ),
            ],
          ),
        ),
      ),

      // ── SOS FAB — gradient, 64dp height ──
      floatingActionButton: Builder(
        builder: (context) {
          final fabCs = Theme.of(context).colorScheme;
          return Semantics(
            button: true,
            label: 'Call emergency services on 101',
            child: Container(
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: const Alignment(-0.97, -0.26),
                end: const Alignment(0.97, 0.26),
                colors: [fabCs.primary, fabCs.primaryContainer],
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: fabCs.onSurface.withValues(alpha: 0.08),
                  offset: const Offset(0, 16),
                  blurRadius: 40,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(32),
                onTap: () async {
                  final Uri callUri = Uri(scheme: 'tel', path: '101');
                  try {
                    await launchUrl(callUri);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Could not open dialer. Please call 101 manually.'),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.phone, color: fabCs.onPrimary, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        'CALL 101',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: fabCs.onPrimary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        },
      ),
    );
  }

  Widget _buildEmergencyCard(
    BuildContext context, {
    required String id,
    required String title,
    required IconData icon,
    required Color color,
  }) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StepScreen(
              emergencyId: id,
              emergencyTitle: title,
              emergencyColor: color,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon in accent-tinted circle (10% opacity chip style)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
