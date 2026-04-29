import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../widgets/glass_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _loading = true);
    final history = await ApiService.getHistory();
    if (mounted) {
      setState(() {
        _history = history;
        _loading = false;
      });
    }
  }

  Color _gradeColor(double score) {
    if (score >= 85) return AppTheme.success;
    if (score >= 70) return const Color(0xFF3B82F6);
    if (score >= 50) return AppTheme.warning;
    return AppTheme.danger;
  }

  String _gradeLabel(double score) {
    if (score >= 85) return 'Excellent';
    if (score >= 70) return 'Good';
    if (score >= 50) return 'Average';
    return 'Needs Work';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prediction History'),
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
        child: _loading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 36, height: 36,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppTheme.primary.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Loading history...', style: TextStyle(color: AppTheme.textMuted, fontSize: 14)),
                  ],
                ),
              )
            : _history.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Icon(Icons.history_rounded, size: 40, color: AppTheme.textMuted),
                        ),
                        const SizedBox(height: 20),
                        const Text('No predictions yet',
                          style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        const Text('Make your first prediction to see it here!',
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 14)),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadHistory,
                    color: AppTheme.primary,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _history.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: GlassCard(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              borderColor: AppTheme.primary.withValues(alpha: 0.15),
                              child: Row(
                                children: [
                                  const Icon(Icons.bar_chart_rounded, size: 20, color: AppTheme.primary),
                                  const SizedBox(width: 10),
                                  Text('${_history.length} prediction${_history.length == 1 ? '' : 's'}',
                                    style: const TextStyle(
                                      color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 15,
                                    )),
                                  const Spacer(),
                                  const Text('Pull to refresh',
                                    style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                                ],
                              ),
                            ),
                          );
                        }

                        final item = _history[index - 1];
                        final score = (item['predicted_score'] ?? 0).toDouble();
                        final date = item['created_at'] ?? '';
                        final inputs = item['input_data'] ?? {};
                        final color = _gradeColor(score);
                        final label = _gradeLabel(score);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: GlassCard(
                            padding: const EdgeInsets.all(16),
                            borderColor: color.withValues(alpha: 0.15),
                            child: Row(
                              children: [
                                Container(
                                  width: 56, height: 56,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [color.withValues(alpha: 0.25), color.withValues(alpha: 0.1)],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: color.withValues(alpha: 0.3)),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(score.toStringAsFixed(0),
                                        style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 20)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text('${score.toStringAsFixed(1)} / 100',
                                            style: const TextStyle(
                                              color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: color.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(label,
                                              style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${inputs['hours_studied'] ?? '-'}h study  ·  ${inputs['sleep_hours'] ?? '-'}h sleep  ·  ${inputs['previous_scores'] ?? '-'}% prev',
                                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                                      ),
                                      if (date.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(date.length > 10 ? date.substring(0, 10) : date,
                                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                                      ],
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted.withValues(alpha: 0.5), size: 22),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}
