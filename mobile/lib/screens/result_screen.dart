import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/glass_card.dart';
import 'predict_screen.dart';

// ─────────────────────────────────────────────────────────────
// TAB 1 — Performance Analysis
// ─────────────────────────────────────────────────────────────
class _PerformanceTab extends StatelessWidget {
  final Map<String, dynamic> prediction;
  final Map<String, dynamic>? engineeredFeatures;

  const _PerformanceTab({required this.prediction, this.engineeredFeatures});

  Color _gradeColor(String grade) {
    switch (grade) {
      case 'excellent': return AppTheme.success;
      case 'good': return const Color(0xFF3B82F6);
      case 'average': return AppTheme.warning;
      default: return AppTheme.danger;
    }
  }

  IconData _gradeIcon(String grade) {
    switch (grade) {
      case 'excellent': return Icons.emoji_events;
      case 'good': return Icons.star;
      case 'average': return Icons.trending_up;
      default: return Icons.warning_amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    final score = (prediction['score'] ?? 0).toDouble();
    final grade = prediction['grade'] ?? 'average';
    final status = prediction['status'] ?? '';
    final message = prediction['message'] ?? '';
    final color = _gradeColor(grade);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Score Hero Card
        GlassCard(
          borderColor: color.withValues(alpha: 0.5),
          child: Column(
            children: [
              Icon(_gradeIcon(grade), size: 56, color: color),
              const SizedBox(height: 8),
              Text(status,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color, letterSpacing: 2)),
              const SizedBox(height: 4),
              Text(score.toStringAsFixed(1),
                style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
              const Text('/ 100', style: TextStyle(color: AppTheme.textMuted, fontSize: 18)),
              const SizedBox(height: 10),
              Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
            ],
          ),
        ),

        // Score Progress Bar
        const SizedBox(height: 16),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Score Breakdown',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Performance Index', style: TextStyle(color: AppTheme.textSecondary)),
                  Text('${score.toStringAsFixed(1)} / 100',
                    style: TextStyle(color: color, fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: score / 100,
                  minHeight: 14,
                  backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
              const SizedBox(height: 16),
              // Grade bands legend
              _GradeBand(label: 'Excellent', range: '90–100', color: AppTheme.success, active: grade == 'excellent'),
              _GradeBand(label: 'Good', range: '80–89', color: const Color(0xFF3B82F6), active: grade == 'good'),
              _GradeBand(label: 'Average', range: '70–79', color: AppTheme.warning, active: grade == 'average'),
              _GradeBand(label: 'Needs Improvement', range: '60–69', color: AppTheme.danger, active: grade == 'needs_improvement'),
              _GradeBand(label: 'Critical', range: '< 60', color: const Color(0xFF7F1D1D), active: grade == 'critical'),
            ],
          ),
        ),

        // Engineered Features
        if (engineeredFeatures != null) ...[
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [
                  Icon(Icons.science_outlined, size: 20, color: AppTheme.secondary),
                  SizedBox(width: 8),
                  Text('Performance Breakdown',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                ]),
                const SizedBox(height: 12),
                _FeatureRow('Study-Sleep Ratio',
                  '${(engineeredFeatures!['study_sleep_ratio'] ?? 0).toStringAsFixed(2)}',
                  Icons.balance, AppTheme.primary),
                _FeatureRow('Total Effort Score',
                  '${engineeredFeatures!['total_effort'] ?? 0}',
                  Icons.fitness_center, AppTheme.secondary),
                _FeatureRow('Prev. Score Normalized',
                  '${((engineeredFeatures!['previous_score_normalized'] ?? 0) * 100).toStringAsFixed(0)}%',
                  Icons.history_edu, AppTheme.success),
                _FeatureRow('Sleep Efficiency',
                  '${(engineeredFeatures!['sleep_efficiency'] ?? 0).toStringAsFixed(2)}',
                  Icons.bedtime, AppTheme.warning),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _GradeBand extends StatelessWidget {
  final String label, range;
  final Color color;
  final bool active;
  const _GradeBand({required this.label, required this.range, required this.color, required this.active});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 10, height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(label,
            style: TextStyle(
              color: active ? color : AppTheme.textMuted,
              fontWeight: active ? FontWeight.w700 : FontWeight.normal,
              fontSize: 13,
            ))),
          Text(range, style: TextStyle(color: active ? color : AppTheme.textMuted, fontSize: 12)),
          if (active) ...[
            const SizedBox(width: 6),
            Icon(Icons.check_circle, size: 14, color: color),
          ],
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _FeatureRow(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13))),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 14)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TAB 2 — Goal Tracker
// ─────────────────────────────────────────────────────────────
class _GoalTab extends StatelessWidget {
  final Map<String, dynamic>? goalAnalysis;
  final List recommendations;

  const _GoalTab({this.goalAnalysis, required this.recommendations});

  @override
  Widget build(BuildContext context) {
    if (goalAnalysis == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.flag_outlined, size: 64, color: AppTheme.textMuted),
              SizedBox(height: 16),
              Text('No target score set',
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
              SizedBox(height: 8),
              Text('Go back and set a target score to see your goal analysis.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textMuted, fontSize: 14)),
            ],
          ),
        ),
      );
    }

    final current = (goalAnalysis!['current_score'] ?? 0).toDouble();
    final target = (goalAnalysis!['target_score'] ?? 0).toDouble();
    final progress = (goalAnalysis!['progress_percentage'] ?? 0).toDouble();
    final gap = (goalAnalysis!['gap'] ?? 0).toDouble();
    final achieved = gap <= 0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Goal Status Card
        GlassCard(
          borderColor: achieved
              ? AppTheme.success.withValues(alpha: 0.5)
              : AppTheme.warning.withValues(alpha: 0.4),
          child: Column(
            children: [
              Icon(
                achieved ? Icons.emoji_events : Icons.flag,
                size: 48,
                color: achieved ? AppTheme.success : AppTheme.warning,
              ),
              const SizedBox(height: 8),
              Text(
                achieved ? 'Goal Achieved! 🎉' : 'Keep Going!',
                style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w800,
                  color: achieved ? AppTheme.success : AppTheme.warning,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _GoalStat('Current', current.toStringAsFixed(1), AppTheme.primary),
                  Container(width: 1, height: 40, color: AppTheme.cardBorder),
                  _GoalStat('Target', target.toStringAsFixed(0), AppTheme.secondary),
                  Container(width: 1, height: 40, color: AppTheme.cardBorder),
                  _GoalStat('Gap', achieved ? '0' : gap.toStringAsFixed(1),
                    achieved ? AppTheme.success : AppTheme.danger),
                ],
              ),
            ],
          ),
        ),

        // Progress Bar
        const SizedBox(height: 16),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Progress to Goal',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  Text('${progress.toStringAsFixed(0)}%',
                    style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w800, fontSize: 18)),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: (progress / 100).clamp(0.0, 1.0),
                  minHeight: 18,
                  backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation(
                    achieved ? AppTheme.success : AppTheme.primary),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                achieved
                    ? 'You\'ve surpassed your target score!'
                    : 'You need ${gap.toStringAsFixed(1)} more points to reach your goal.',
                style: TextStyle(
                  color: achieved ? AppTheme.success : AppTheme.textMuted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        // Recommendations
        if (recommendations.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Row(children: [
            Icon(Icons.lightbulb_outline, size: 20, color: AppTheme.warning),
            SizedBox(width: 8),
            Text('Action Plan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          ]),
          const SizedBox(height: 10),
          ...recommendations.asMap().entries.map((entry) {
            final i = entry.key;
            final rec = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GlassCard(
                padding: const EdgeInsets.all(14),
                borderColor: AppTheme.warning.withValues(alpha: 0.3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        color: AppTheme.warning.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text('${i + 1}',
                          style: const TextStyle(color: AppTheme.warning, fontWeight: FontWeight.w800, fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(rec['title'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.warning)),
                          const SizedBox(height: 4),
                          Text(rec['description'] ?? '',
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ],
    );
  }
}

class _GoalStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _GoalStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 22)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TAB 3 — Peer Comparison
// ─────────────────────────────────────────────────────────────
class _PeerTab extends StatelessWidget {
  final List peerComparison;
  const _PeerTab({required this.peerComparison});

  @override
  Widget build(BuildContext context) {
    if (peerComparison.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: AppTheme.textMuted),
            SizedBox(height: 16),
            Text('No comparison data', style: TextStyle(color: AppTheme.textMuted, fontSize: 16)),
          ],
        ),
      );
    }

    final strengths = peerComparison.where((c) => c['is_strength'] == true).toList();
    final improvements = peerComparison.where((c) => c['is_strength'] != true).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary chips
        GlassCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _SummaryChip('${strengths.length}', 'Strengths', AppTheme.success, Icons.arrow_upward),
              Container(width: 1, height: 40, color: AppTheme.cardBorder),
              _SummaryChip('${improvements.length}', 'To Improve', AppTheme.warning, Icons.arrow_downward),
            ],
          ),
        ),

        // Bar chart style comparison
        const SizedBox(height: 16),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(children: [
                Icon(Icons.bar_chart, size: 20, color: AppTheme.primary),
                SizedBox(width: 8),
                Text('You vs Class Average',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              ]),
              const SizedBox(height: 4),
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _Legend(color: AppTheme.primary, label: 'You'),
                  SizedBox(width: 12),
                  _Legend(color: AppTheme.textMuted, label: 'Class Avg'),
                ],
              ),
              const SizedBox(height: 12),
              ...peerComparison.map((comp) {
                final studentScore = (comp['student_score'] ?? 0).toDouble();
                final classAvg = (comp['class_average'] ?? 0).toDouble();
                final isStrength = comp['is_strength'] == true;
                final diff = (comp['difference'] ?? 0).toDouble();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(comp['category'] ?? '',
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
                          Row(children: [
                            Icon(
                              diff >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                              size: 14,
                              color: isStrength ? AppTheme.success : AppTheme.warning,
                            ),
                            Text(
                              '${diff >= 0 ? '+' : ''}${diff.toStringAsFixed(1)}%',
                              style: TextStyle(
                                color: isStrength ? AppTheme.success : AppTheme.warning,
                                fontWeight: FontWeight.w700, fontSize: 12,
                              ),
                            ),
                          ]),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // You bar
                      _CompBar(value: studentScore / 100, color: AppTheme.primary, label: '${studentScore.toStringAsFixed(0)}%'),
                      const SizedBox(height: 4),
                      // Class avg bar
                      _CompBar(value: classAvg / 100, color: AppTheme.textMuted, label: '${classAvg.toStringAsFixed(0)}%'),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

        // Strengths
        if (strengths.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Row(children: [
            Icon(Icons.star, size: 20, color: AppTheme.success),
            SizedBox(width: 8),
            Text('Your Strengths',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          ]),
          const SizedBox(height: 8),
          ...strengths.map((comp) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GlassCard(
              padding: const EdgeInsets.all(12),
              borderColor: AppTheme.success.withValues(alpha: 0.4),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, size: 20, color: AppTheme.success),
                  const SizedBox(width: 10),
                  Expanded(child: Text(comp['category'] ?? '',
                    style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600))),
                  Text('+${(comp['difference'] ?? 0).toStringAsFixed(1)}% above avg',
                    style: const TextStyle(color: AppTheme.success, fontSize: 12, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          )),
        ],

        // Areas to improve
        if (improvements.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Row(children: [
            Icon(Icons.trending_up, size: 20, color: AppTheme.warning),
            SizedBox(width: 8),
            Text('Areas to Improve',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          ]),
          const SizedBox(height: 8),
          ...improvements.map((comp) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GlassCard(
              padding: const EdgeInsets.all(12),
              borderColor: AppTheme.warning.withValues(alpha: 0.3),
              child: Row(
                children: [
                  const Icon(Icons.arrow_upward, size: 20, color: AppTheme.warning),
                  const SizedBox(width: 10),
                  Expanded(child: Text(comp['category'] ?? '',
                    style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600))),
                  Text('${(comp['difference'] ?? 0).toStringAsFixed(1)}% below avg',
                    style: const TextStyle(color: AppTheme.warning, fontSize: 12, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          )),
        ],
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String count, label;
  final Color color;
  final IconData icon;
  const _SummaryChip(this.count, this.label, this.color, this.icon);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(count, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 22)),
        ]),
        Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(color: color, fontSize: 11)),
    ]);
  }
}

class _CompBar extends StatelessWidget {
  final double value;
  final Color color;
  final String label;
  const _CompBar({required this.value, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 36,
          child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TAB 4 — Study Insights
// ─────────────────────────────────────────────────────────────
class _InsightsTab extends StatelessWidget {
  final List insights;
  const _InsightsTab({required this.insights});

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.insights, size: 64, color: AppTheme.textMuted),
            SizedBox(height: 16),
            Text('No insights available', style: TextStyle(color: AppTheme.textMuted, fontSize: 16)),
          ],
        ),
      );
    }

    final successInsights = insights.where((i) => i['level'] == 'success').toList();
    final warningInsights = insights.where((i) => i['level'] == 'warning').toList();
    final infoInsights = insights.where((i) => i['level'] != 'success' && i['level'] != 'warning').toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary banner
        GlassCard(
          borderColor: AppTheme.primary.withValues(alpha: 0.3),
          child: Row(
            children: [
              const Icon(Icons.lightbulb_outline, size: 28, color: AppTheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Study Insights',
                      style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
                    Text('${insights.length} tips based on your study habits',
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),

        if (successInsights.isNotEmpty) ...[
          const SizedBox(height: 16),
          _InsightSection(title: 'What\'s Working', icon: Icons.check_circle_outline,
            color: AppTheme.success, insights: successInsights),
        ],
        if (warningInsights.isNotEmpty) ...[
          const SizedBox(height: 16),
          _InsightSection(title: 'Watch Out For', icon: Icons.warning_amber_outlined,
            color: AppTheme.warning, insights: warningInsights),
        ],
        if (infoInsights.isNotEmpty) ...[
          const SizedBox(height: 16),
          _InsightSection(title: 'Study Tips', icon: Icons.lightbulb_outline,
            color: const Color(0xFF3B82F6), insights: infoInsights),
        ],
      ],
    );
  }
}

class _InsightSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List insights;
  const _InsightSection({required this.title, required this.icon, required this.color, required this.insights});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
        ]),
        const SizedBox(height: 8),
        ...insights.map((ins) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GlassCard(
            padding: const EdgeInsets.all(14),
            borderColor: color.withValues(alpha: 0.35),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ins['title'] ?? '',
                  style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 14)),
                const SizedBox(height: 6),
                Text(ins['description'] ?? '',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        )),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// MAIN ResultScreen — Tabbed Layout
// ─────────────────────────────────────────────────────────────
class ResultScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  const ResultScreen({super.key, required this.data});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prediction = widget.data['prediction'] ?? {};
    final score = (prediction['score'] ?? 0).toDouble();
    final grade = prediction['grade'] ?? 'average';
    final goalAnalysis = widget.data['goal_analysis'] as Map<String, dynamic>?;
    final recommendations = widget.data['recommendations'] as List? ?? [];
    final insights = widget.data['insights'] as List? ?? [];
    final peerComparison = widget.data['peer_comparison'] as List? ?? [];
    final engineeredFeatures = widget.data['engineered_features'] as Map<String, dynamic>?;
    final weeklyRoadmap = widget.data['weekly_roadmap'] as List? ?? [];
    final subjectPriorities = widget.data['subject_priorities'] as List? ?? [];

    // Grade color for the score badge in AppBar
    Color gradeColor;
    switch (grade) {
      case 'excellent': gradeColor = AppTheme.success; break;
      case 'good': gradeColor = const Color(0xFF3B82F6); break;
      case 'average': gradeColor = AppTheme.warning; break;
      default: gradeColor = AppTheme.danger;
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Results'),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: gradeColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: gradeColor.withValues(alpha: 0.5)),
              ),
              child: Text(
                score.toStringAsFixed(1),
                style: TextStyle(color: gradeColor, fontWeight: FontWeight.w900, fontSize: 14),
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          indicatorWeight: 3,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textMuted,
          labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(icon: Icon(Icons.analytics_outlined, size: 18), text: 'Score'),
            Tab(icon: Icon(Icons.flag_outlined, size: 18), text: 'Goal'),
            Tab(icon: Icon(Icons.people_outline, size: 18), text: 'Peers'),
            Tab(icon: Icon(Icons.insights, size: 18), text: 'Insights'),
            Tab(icon: Icon(Icons.map_outlined, size: 18), text: 'Roadmap'),
            Tab(icon: Icon(Icons.priority_high, size: 18), text: 'Priorities'),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [AppTheme.bgDark, AppTheme.bgMid, Color(0xFF2D0000)],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _PerformanceTab(prediction: prediction, engineeredFeatures: engineeredFeatures),
                  _GoalTab(goalAnalysis: goalAnalysis, recommendations: recommendations),
                  _PeerTab(peerComparison: peerComparison),
                  _InsightsTab(insights: insights),
                  _RoadmapTab(roadmap: weeklyRoadmap),
                  _PrioritiesTab(priorities: subjectPriorities),
                ],
              ),
            ),
            // Bottom action bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              decoration: BoxDecoration(
                color: AppTheme.bgDark.withValues(alpha: 0.8),
                border: Border(top: BorderSide(color: AppTheme.cardBorder)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.home, size: 18),
                        label: const Text('Home'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.textPrimary,
                          side: const BorderSide(color: AppTheme.cardBorder),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pushReplacement(
                          context, MaterialPageRoute(builder: (_) => const PredictScreen())),
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Predict Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
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
}

// ─────────────────────────────────────────────────────────────
// TAB 5 — Weekly Roadmap
// ─────────────────────────────────────────────────────────────
class _RoadmapTab extends StatelessWidget {
  final List roadmap;
  const _RoadmapTab({required this.roadmap});

  Color _intensityColor(String intensity) {
    switch (intensity) {
      case 'intensive': return AppTheme.danger;
      case 'moderate': return AppTheme.warning;
      case 'light': return const Color(0xFF3B82F6);
      default: return AppTheme.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (roadmap.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map_outlined, size: 64, color: AppTheme.textMuted),
              SizedBox(height: 16),
              Text('Set a target score to get your roadmap',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textMuted, fontSize: 16)),
            ],
          ),
        ),
      );
    }

    final intensity = roadmap.isNotEmpty ? (roadmap[0]['intensity'] ?? 'light') : 'light';
    final intensityColor = _intensityColor(intensity);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header banner
        GlassCard(
          borderColor: intensityColor.withValues(alpha: 0.4),
          child: Row(
            children: [
              Icon(Icons.map_outlined, size: 28, color: intensityColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('7-Day Study Roadmap',
                      style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
                    Text('${intensity[0].toUpperCase()}${intensity.substring(1)} intensity plan',
                      style: TextStyle(color: intensityColor, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Day cards
        ...roadmap.map((day) {
          final dayColor = _intensityColor(day['intensity'] ?? 'light');
          final tasks = (day['tasks'] as List?) ?? [];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GlassCard(
              borderColor: dayColor.withValues(alpha: 0.3),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: dayColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text('${day['day_number']}',
                            style: TextStyle(color: dayColor, fontWeight: FontWeight.w900, fontSize: 16)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(day['day'] ?? '',
                              style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                            Text(day['focus'] ?? '',
                              style: TextStyle(color: dayColor, fontWeight: FontWeight.w700, fontSize: 14)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: dayColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('${day['study_hours']}h',
                          style: TextStyle(color: dayColor, fontWeight: FontWeight.w800, fontSize: 13)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Tasks
                  ...tasks.map((task) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_box_outline_blank, size: 16, color: dayColor),
                        const SizedBox(width: 8),
                        Expanded(child: Text(task.toString(),
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13))),
                      ],
                    ),
                  )),
                  const SizedBox(height: 10),
                  // Tip
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb_outline, size: 14, color: AppTheme.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(day['tip'] ?? '',
                            style: const TextStyle(color: AppTheme.primary, fontSize: 12, fontStyle: FontStyle.italic)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TAB 6 — Subject Priorities
// ─────────────────────────────────────────────────────────────
class _PrioritiesTab extends StatelessWidget {
  final List priorities;
  const _PrioritiesTab({required this.priorities});

  Color _urgencyColor(String urgency) {
    switch (urgency) {
      case 'critical': return AppTheme.danger;
      case 'high': return AppTheme.warning;
      case 'medium': return const Color(0xFF3B82F6);
      default: return AppTheme.success;
    }
  }

  IconData _urgencyIcon(String urgency) {
    switch (urgency) {
      case 'critical': return Icons.error_outline;
      case 'high': return Icons.warning_amber_outlined;
      case 'medium': return Icons.info_outline;
      default: return Icons.check_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (priorities.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.priority_high, size: 64, color: AppTheme.textMuted),
            SizedBox(height: 16),
            Text('No priorities available', style: TextStyle(color: AppTheme.textMuted, fontSize: 16)),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GlassCard(
          borderColor: AppTheme.primary.withValues(alpha: 0.3),
          child: Row(
            children: [
              const Icon(Icons.priority_high, size: 28, color: AppTheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Study Priority List',
                      style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
                    Text('${priorities.length} areas ranked by urgency',
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        ...priorities.map((p) {
          final urgency = p['urgency'] ?? 'medium';
          final color = _urgencyColor(urgency);
          final icon = _urgencyIcon(urgency);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GlassCard(
              borderColor: color.withValues(alpha: 0.35),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text('#${p['rank']}',
                            style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 13)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(p['area'] ?? '',
                          style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 14)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icon, size: 12, color: color),
                            const SizedBox(width: 3),
                            Text(urgency.toUpperCase(),
                              style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(p['reason'] ?? '',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.play_arrow, size: 16, color: color),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(p['action'] ?? '',
                            style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 14, color: AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Text('Time allocation: ${p['time_allocation']}',
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
