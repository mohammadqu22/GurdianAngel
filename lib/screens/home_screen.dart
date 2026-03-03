import 'package:flutter/material.dart';
import '../models/emergency.dart';
import 'emergency_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
        backgroundColor: const Color(0xFFE53935), // Red
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
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
            const SizedBox(height: 24),

            // Emergency Category Grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2, // 2 columns
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildEmergencyCard(
                    context,
                    title: 'Burns',
                    icon: Icons.local_fire_department,
                    color: const Color(0xFFFF5722), // Orange-red
                  ),
                  _buildEmergencyCard(
                    context,
                    title: 'Choking',
                    icon: Icons.air,
                    color: const Color(0xFF2196F3), // Blue
                  ),
                  _buildEmergencyCard(
                    context,
                    title: 'CPR',
                    icon: Icons.favorite,
                    color: const Color(0xFFE53935), // Red
                  ),
                  _buildEmergencyCard(
                    context,
                    title: 'Bleeding',
                    icon: Icons.water_drop,
                    color: const Color(0xFFD32F2F), // Dark red
                  ),
                  _buildEmergencyCard(
                    context,
                    title: 'Fractures',
                    icon: Icons.accessible,
                    color: const Color(0xFF9C27B0), // Purple
                  ),
                  _buildEmergencyCard(
                    context,
                    title: 'Seizures',
                    icon: Icons.warning_amber_rounded,
                    color: const Color(0xFFFFA726), // Orange
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      
      // Emergency Call Button (Floating)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Implement emergency call
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Emergency Call Feature - Coming Soon'),
              duration: Duration(seconds: 2),
            ),
          );
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

  // Emergency Card Widget
  Widget _buildEmergencyCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        // Find the emergency from sample data
          final emergencies = getSampleEmergencies();
          final emergency = emergencies.firstWhere(
            (e) => e.name == title,
          );
          
          // Navigate to detail screen
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
            // Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            
            // Title
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