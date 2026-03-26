import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class StepScreen extends StatefulWidget {
  final String emergencyId;
  final String emergencyTitle;
  final Color emergencyColor;

  const StepScreen({
    super.key,
    required this.emergencyId,
    required this.emergencyTitle,
    required this.emergencyColor,
  });

  @override
  State<StepScreen> createState() => _StepScreenState();
}

class _StepScreenState extends State<StepScreen> {
  List<dynamic> _steps = [];
  List<dynamic> _warnings = [];
  int _currentStep = 0;
  bool _loading = true;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _loadProtocol();
  }

  Future<void> _loadProtocol() async {
    try {
      final String data = await rootBundle
          .loadString('assets/data/${widget.emergencyId}.json');
      final Map<String, dynamic> json = jsonDecode(data);
      setState(() {
        _steps = json['steps'];
        _warnings = json['warnings'] ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      setState(() {
        _completed = true;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.emergencyTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: widget.emergencyColor,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _completed
              ? _buildCompletedScreen()
              : _buildStepScreen(),
    );
  }

  Widget _buildStepScreen() {
    final step = _steps[_currentStep];
    final totalSteps = _steps.length;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${_currentStep + 1} of $totalSteps',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${((_currentStep + 1) / totalSteps * 100).round()}%',
                style: TextStyle(
                  fontSize: 14,
                  color: widget.emergencyColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (_currentStep + 1) / totalSteps,
              backgroundColor: Colors.grey[200],
              valueColor:
                  AlwaysStoppedAnimation<Color>(widget.emergencyColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 32),

          // Step card
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: widget.emergencyColor.withOpacity(0.15),
                    spreadRadius: 2,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: widget.emergencyColor.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Step number circle
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: widget.emergencyColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${_currentStep + 1}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Step title
                  Text(
                    step['title'],
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: widget.emergencyColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Step instruction
                  Text(
                    step['instruction'],
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Color(0xFF212121),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Navigation buttons
          Row(
            children: [
              if (_currentStep > 0)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _previousStep,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Previous'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: widget.emergencyColor),
                      foregroundColor: widget.emergencyColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              if (_currentStep > 0) const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _nextStep,
                  icon: Icon(
                    _currentStep == totalSteps - 1
                        ? Icons.check
                        : Icons.arrow_forward,
                  ),
                  label: Text(
                    _currentStep == totalSteps - 1 ? 'Done' : 'Next Step',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.emergencyColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Warnings section
          if (_warnings.isNotEmpty) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _showWarningsDialog(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: Colors.orange[700], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'View important warnings',
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.chevron_right, color: Colors.orange[700]),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompletedScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.green[50],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle,
                  color: Colors.green, size: 64),
            ),
            const SizedBox(height: 24),
            const Text(
              'Treatment Complete',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You have completed all steps for ${widget.emergencyTitle}.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.orange[700]),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'This app does not replace professional medical care. Seek a doctor if needed.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.home),
              label: const Text('Back to Home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWarningsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange[700]),
            const SizedBox(width: 8),
            const Text('Important Warnings'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _warnings
              .map((w) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.cancel, color: Colors.red, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(w)),
                      ],
                    ),
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}