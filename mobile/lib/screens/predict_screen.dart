import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../widgets/glass_card.dart';
import 'result_screen.dart';

class PredictScreen extends StatefulWidget {
  const PredictScreen({super.key});

  @override
  State<PredictScreen> createState() => _PredictScreenState();
}

class _PredictScreenState extends State<PredictScreen> with SingleTickerProviderStateMixin {
  double _hoursStudied = 6;
  double _previousScores = 75;
  bool _extracurricular = false;
  double _sleepHours = 7;
  double _samplePapers = 4;
  double _targetScore = 85;
  bool _loading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _predict() async {
    setState(() => _loading = true);
    try {
      final result = await ApiService.predict(
        hoursStudied: _hoursStudied.round(),
        previousScores: _previousScores.round(),
        extracurricular: _extracurricular,
        sleepHours: _sleepHours.round(),
        samplePapers: _samplePapers.round(),
        targetScore: _targetScore.round(),
      );
      if (mounted) {
        Navigator.push(context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => ResultScreen(data: result),
            transitionsBuilder: (_, a, __, child) =>
              SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
                  .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
                child: FadeTransition(opacity: a, child: child),
              ),
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 18),
                const SizedBox(width: 10),
                Expanded(child: Text(ApiService.getErrorMessage(e))),
              ],
            ),
            backgroundColor: AppTheme.danger.withValues(alpha: 0.9),
          ),
        );
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  Widget _buildSlider({
    required String label,
    required IconData icon,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required Function(double) onChanged,
    String? unit,
    Color color = AppTheme.primary,
  }) {
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
      borderColor: color.withValues(alpha: 0.12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 17, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label,
                  style: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 14)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${value.round()}${unit ?? ''}',
                  style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 17),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: value, min: min, max: max, divisions: divisions,
              activeColor: color,
              inactiveColor: color.withValues(alpha: 0.15),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Predict Performance'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF0F172A), Color(0xFF1E1B4B), Color(0xFF312E81)],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  children: [
                    _buildSlider(
                      label: 'Study Hours / Day',
                      icon: Icons.menu_book_rounded,
                      value: _hoursStudied, min: 0, max: 12, divisions: 24,
                      onChanged: (v) => setState(() => _hoursStudied = v),
                      unit: 'h',
                      color: AppTheme.primary,
                    ),
                    const SizedBox(height: 10),
                    _buildSlider(
                      label: 'Previous Scores',
                      icon: Icons.assessment_rounded,
                      value: _previousScores, min: 0, max: 100, divisions: 100,
                      onChanged: (v) => setState(() => _previousScores = v),
                      unit: '%',
                      color: const Color(0xFF3B82F6),
                    ),
                    const SizedBox(height: 10),

                    // Extracurricular toggle
                    GlassCard(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                      borderColor: AppTheme.secondary.withValues(alpha: 0.12),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: AppTheme.secondary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.emoji_events_rounded, size: 17, color: AppTheme.secondary),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text('Extracurricular Activities',
                              style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 14)),
                          ),
                          Transform.scale(
                            scale: 0.85,
                            child: Switch(
                              value: _extracurricular,
                              activeColor: AppTheme.secondary,
                              activeTrackColor: AppTheme.secondary.withValues(alpha: 0.3),
                              inactiveThumbColor: AppTheme.textMuted,
                              inactiveTrackColor: AppTheme.cardBorder,
                              onChanged: (v) => setState(() => _extracurricular = v),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    _buildSlider(
                      label: 'Sleep Hours / Night',
                      icon: Icons.bedtime_rounded,
                      value: _sleepHours, min: 4, max: 12, divisions: 16,
                      onChanged: (v) => setState(() => _sleepHours = v),
                      unit: 'h',
                      color: AppTheme.accent,
                    ),
                    const SizedBox(height: 10),
                    _buildSlider(
                      label: 'Practice Papers Done',
                      icon: Icons.description_rounded,
                      value: _samplePapers, min: 0, max: 10, divisions: 10,
                      onChanged: (v) => setState(() => _samplePapers = v),
                      color: AppTheme.success,
                    ),
                    const SizedBox(height: 10),
                    _buildSlider(
                      label: 'Target Score',
                      icon: Icons.flag_rounded,
                      value: _targetScore, min: 50, max: 100, divisions: 50,
                      onChanged: (v) => setState(() => _targetScore = v),
                      color: AppTheme.warning,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              // Bottom button
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: BoxDecoration(
                  color: AppTheme.bgDark.withValues(alpha: 0.9),
                  border: Border(top: BorderSide(color: AppTheme.cardBorder)),
                ),
                child: SafeArea(
                  top: false,
                  child: SizedBox(
                    height: 54,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _predict,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        disabledBackgroundColor: AppTheme.primary.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: _loading
                          ? const SizedBox(height: 24, width: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.auto_awesome, size: 20),
                                SizedBox(width: 10),
                                Text('Predict Performance',
                                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                              ],
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
}
