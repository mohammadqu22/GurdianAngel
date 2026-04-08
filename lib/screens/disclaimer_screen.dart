import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import '../core/app_theme.dart';

class DisclaimerScreen extends StatelessWidget {
  const DisclaimerScreen({super.key, required this.onThemeModeChanged});

  final ValueChanged<ThemeMode> onThemeModeChanged;

  Future<void> _acceptDisclaimer(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('disclaimer_accepted', true);

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(onThemeModeChanged: onThemeModeChanged),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),

                      // ── App Icon and Title ──
                      Center(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: cs.primary.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.medical_services,
                                size: 56,
                                color: cs.primary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Guardian Angel',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: cs.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Emergency First Aid Guide',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // ── Important Notice ──
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'IMPORTANT MEDICAL NOTICE',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: cs.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'This application is a decision-support tool and DOES NOT replace professional medical care, diagnosis, or treatment.',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: cs.onSurface,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'In the event of a life-threatening emergency, always contact your local emergency services (101) immediately.',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: cs.onSurface,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Emergency Instructions ──
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.phone_in_talk, color: cs.primary, size: 24),
                                const SizedBox(width: 10),
                                Text(
                                  'In Case of Emergency:',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: cs.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildBulletPoint(context, 'Call 101 (Magen David Adom) immediately'),
                            _buildBulletPoint(context, 'Use this app as a guide while waiting for help'),
                            _buildBulletPoint(context, 'Seek professional medical attention after first aid'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Medical Sources ──
                      Text(
                        'Verified Medical Sources',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSourceItem(context, 'American Red Cross — First Aid Guidelines'),
                      _buildSourceItem(context, 'World Health Organization — Emergency Care'),
                      _buildSourceItem(context, 'American Heart Association — CPR Standards'),
                      _buildSourceItem(context, 'Magen David Adom — Israeli Emergency Protocols'),

                      const SizedBox(height: 24),

                      // ── Legal Notice ──
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Text(
                          'By continuing, you acknowledge that this guidance does not replace emergency medical services and that you will call 101 for serious medical situations.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Guardian Angel v1.0.0 • Clinical Sentinel UI',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: cs.outline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Accept Button — gradient CTA ──
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: const Alignment(-0.97, -0.26),
                    end: const Alignment(0.97, 0.26),
                    colors: [cs.primary, cs.primaryContainer],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: [
                    BoxShadow(
                      color: cs.onSurface.withValues(alpha: 0.08),
                      offset: const Offset(0, 16),
                      blurRadius: 40,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    onTap: () => _acceptDisclaimer(context),
                    child: Center(
                      child: Text(
                        'I UNDERSTAND — CONTINUE',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: cs.onPrimary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBulletPoint(BuildContext context, String text) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, color: cs.primary, size: 14),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: cs.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceItem(BuildContext context, String source) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified, color: cs.tertiary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              source,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: cs.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
