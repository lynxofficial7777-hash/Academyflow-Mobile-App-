import 'dart:async';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/glass_card.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> with TickerProviderStateMixin {
  static const int _studyMinutes = 25;
  static const int _breakMinutes = 5;

  int _secondsLeft = _studyMinutes * 60;
  bool _isRunning = false;
  bool _isBreak = false;
  int _sessionsCompleted = 0;
  Timer? _timer;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startStop() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      setState(() => _isRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_secondsLeft > 0) {
          setState(() => _secondsLeft--);
        } else {
          _timer?.cancel();
          setState(() {
            _isRunning = false;
            if (!_isBreak) {
              _sessionsCompleted++;
              _isBreak = true;
              _secondsLeft = _breakMinutes * 60;
            } else {
              _isBreak = false;
              _secondsLeft = _studyMinutes * 60;
            }
          });
        }
      });
    }
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isBreak = false;
      _secondsLeft = _studyMinutes * 60;
    });
  }

  String get _timeString {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  double get _progress {
    final total = _isBreak ? _breakMinutes * 60 : _studyMinutes * 60;
    return 1 - (_secondsLeft / total);
  }

  @override
  Widget build(BuildContext context) {
    final color = _isBreak ? AppTheme.success : AppTheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Timer'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0A0A), Color(0xFF1A0000), Color(0xFF2D0000)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 16),

                // Mode label
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: color.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    _isBreak ? 'Break Time' : 'Study Session',
                    style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),

                const SizedBox(height: 48),

                // Timer circle
                ScaleTransition(
                  scale: _isRunning ? _pulseAnim : const AlwaysStoppedAnimation(1.0),
                  child: SizedBox(
                    width: 240,
                    height: 240,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 240,
                          height: 240,
                          child: CircularProgressIndicator(
                            value: _progress,
                            strokeWidth: 8,
                            backgroundColor: color.withValues(alpha: 0.1),
                            valueColor: AlwaysStoppedAnimation(color),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_timeString,
                              style: TextStyle(
                                fontSize: 58,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.textPrimary,
                                letterSpacing: 2,
                              ),
                            ),
                            Text(_isBreak ? 'rest' : 'focus',
                              style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Reset
                    GestureDetector(
                      onTap: _reset,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppTheme.cardBg,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.cardBorder),
                        ),
                        child: const Icon(Icons.refresh_rounded, color: AppTheme.textMuted, size: 26),
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Play/Pause
                    GestureDetector(
                      onTap: _startStop,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color, color.withValues(alpha: 0.7)],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.4),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 38,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Sessions counter
                GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  borderColor: AppTheme.primary.withValues(alpha: 0.2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _InfoItem('Sessions', '$_sessionsCompleted', AppTheme.primary, Icons.check_circle_outline),
                      Container(width: 1, height: 36, color: AppTheme.cardBorder),
                      _InfoItem('Focus Time', '${_sessionsCompleted * 25}m', const Color(0xFFFF6D00), Icons.timer_outlined),
                      Container(width: 1, height: 36, color: AppTheme.cardBorder),
                      _InfoItem('Next', _isBreak ? 'Study' : 'Break', AppTheme.success, Icons.swap_horiz_rounded),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Tips
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  borderColor: AppTheme.cardBorder,
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb_outline, color: AppTheme.warning, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _sessionsCompleted == 0
                              ? 'Study for 25 minutes, then take a 5 minute break.'
                              : _sessionsCompleted < 4
                                  ? 'Keep going! After 4 sessions take a longer 15-30 min break.'
                                  : 'Great work! Take a longer break — you have earned it.',
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  const _InfoItem(this.label, this.value, this.color, this.icon);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 16)),
        Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
      ],
    );
  }
}
