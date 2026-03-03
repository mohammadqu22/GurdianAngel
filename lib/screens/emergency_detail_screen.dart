import 'package:flutter/material.dart';
import '../models/emergency.dart';

class EmergencyDetailScreen extends StatelessWidget {
  final Emergency emergency;

  const EmergencyDetailScreen({
    super.key,
    required this.emergency,
  });

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'fire':
        return Icons.local_fire_department;
      case 'air':
        return Icons.air;
      case 'favorite':
        return Icons.favorite;
      case 'water_drop':
        return Icons.water_drop;
      case 'accessible':
        return Icons.accessible;
      case 'warning_amber':
        return Icons.warning_amber_rounded;
      default:
        return Icons.medical_services;
    }
  }

  Color _getColor() {
    return Color(int.parse(emergency.color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Guardian Angel',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFE53935),
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon and Title
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: _getColor().withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getIconData(emergency.icon),
                        size: 80,
                        color: _getColor(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      emergency.name,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: _getColor(),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),

              // Description
              Text(
                'About This Emergency',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                emergency.description,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.grey[700],
                ),
              ),

              const SizedBox(height: 32),

              // Start Guide Button
              ElevatedButton(
                onPressed: () {
                  // TODO: Navigate to step-by-step screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Step-by-step guide coming soon!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getColor(),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Start Guide',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 24),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Important Warnings
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange[300]!,
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange[700],
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Important Guidelines',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...emergency.warnings.map((warning) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.orange[700],
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              warning,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[800],
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Medical Disclaimer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This app provides guidance only. Always call emergency services (101) for serious situations.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      // Emergency Call Button
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
}