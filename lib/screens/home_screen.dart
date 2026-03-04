import 'package:flutter/material.dart';
import '../models/emergency.dart';
import 'emergency_detail_screen.dart';
import 'settings_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // All emergencies list
  final List<Map<String, dynamic>> _allEmergencies = [
    {'title': 'Burns', 'icon': Icons.local_fire_department, 'color': Color(0xFFFF5722)},
    {'title': 'Choking', 'icon': Icons.air, 'color': Color(0xFF2196F3)},
    {'title': 'CPR', 'icon': Icons.favorite, 'color': Color(0xFFE53935)},
    {'title': 'Bleeding', 'icon': Icons.water_drop, 'color': Color(0xFFD32F2F)},
    {'title': 'Fractures', 'icon': Icons.accessible, 'color': Color(0xFF9C27B0)},
    {'title': 'Seizures', 'icon': Icons.warning_amber_rounded, 'color': Color(0xFFFFA726)},
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Guardian Angel',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: const Color(0xFFE53935),
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Text
            const Text(
              'Select Emergency Type',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose the emergency situation for step-by-step guidance',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),

            // Search Bar
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search emergency...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFFE53935)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE53935), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 16),

            // Grid or "No results" message
            Expanded(
              child: _filteredEmergencies.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey),
                          SizedBox(height: 12),
                          Text(
                            'No emergency found',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
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

      // Emergency Call Button (Floating)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final Uri callUri = Uri(scheme: 'tel', path: '101');
          try {
            await launchUrl(callUri);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Could not open dialer. Please call 101 manually.'),
                duration: Duration(seconds: 3),
              ),
            );
          }
        },
        backgroundColor: const Color(0xFFE53935),
        icon: const Icon(Icons.phone, color: Colors.white),
        label: const Text(
          'Call 101',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        final emergencies = getSampleEmergencies();
        final emergency = emergencies.firstWhere(
          (e) => e.name == title,
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EmergencyDetailScreen(emergency: emergency),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}