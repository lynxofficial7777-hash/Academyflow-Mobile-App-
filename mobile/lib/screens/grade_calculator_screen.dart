import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/glass_card.dart';

class GradeCalculatorScreen extends StatefulWidget {
  const GradeCalculatorScreen({super.key});

  @override
  State<GradeCalculatorScreen> createState() => _GradeCalculatorScreenState();
}

class _GradeCalculatorScreenState extends State<GradeCalculatorScreen> {
  final List<_Subject> _subjects = [
    _Subject(),
    _Subject(),
    _Subject(),
  ];

  void _addSubject() {
    setState(() => _subjects.add(_Subject()));
  }

  void _removeSubject(int i) {
    if (_subjects.length > 1) setState(() => _subjects.removeAt(i));
  }

  double get _gpa {
    double totalPoints = 0;
    double totalCredits = 0;
    for (final s in _subjects) {
      final score = double.tryParse(s.scoreCtrl.text) ?? 0;
      final credit = double.tryParse(s.creditCtrl.text) ?? 1;
      totalPoints += score * credit;
      totalCredits += credit;
    }
    if (totalCredits == 0) return 0;
    return totalPoints / totalCredits;
  }

  double get _percentage {
    double total = 0;
    int count = 0;
    for (final s in _subjects) {
      final score = double.tryParse(s.scoreCtrl.text);
      if (score != null) {
        total += score;
        count++;
      }
    }
    if (count == 0) return 0;
    return total / count;
  }

  String _letterGrade(double score) {
    if (score >= 90) return 'A+';
    if (score >= 85) return 'A';
    if (score >= 80) return 'B+';
    if (score >= 75) return 'B';
    if (score >= 70) return 'C+';
    if (score >= 65) return 'C';
    if (score >= 60) return 'D';
    return 'F';
  }

  Color _gradeColor(double score) {
    if (score >= 80) return AppTheme.success;
    if (score >= 65) return AppTheme.warning;
    return AppTheme.danger;
  }

  @override
  void dispose() {
    for (final s in _subjects) {
      s.nameCtrl.dispose();
      s.scoreCtrl.dispose();
      s.creditCtrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final avg = _percentage;
    final color = _gradeColor(avg);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grade Calculator'),
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
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Result card
                  GlassCard(
                    borderColor: color.withValues(alpha: 0.4),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text(avg.toStringAsFixed(1),
                              style: TextStyle(color: color, fontSize: 42, fontWeight: FontWeight.w900)),
                            Text('Average %', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                          ],
                        ),
                        Container(width: 1, height: 56, color: AppTheme.cardBorder),
                        Column(
                          children: [
                            Text(_letterGrade(avg),
                              style: TextStyle(color: color, fontSize: 42, fontWeight: FontWeight.w900)),
                            Text('Grade', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                          ],
                        ),
                        Container(width: 1, height: 56, color: AppTheme.cardBorder),
                        Column(
                          children: [
                            Text(_gpa.toStringAsFixed(2),
                              style: TextStyle(color: color, fontSize: 42, fontWeight: FontWeight.w900)),
                            Text('Weighted', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Subject headers
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      children: const [
                        Expanded(flex: 3, child: Text('Subject', style: TextStyle(color: AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.w600))),
                        Expanded(flex: 2, child: Text('Score %', style: TextStyle(color: AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.w600))),
                        Expanded(flex: 1, child: Text('Credit', style: TextStyle(color: AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.w600))),
                        SizedBox(width: 32),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subject rows
                  ..._subjects.asMap().entries.map((e) {
                    final i = e.key;
                    final s = e.value;
                    final score = double.tryParse(s.scoreCtrl.text) ?? 0;
                    final sc = _gradeColor(score);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GlassCard(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        borderColor: AppTheme.cardBorder,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: s.nameCtrl,
                                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                                decoration: const InputDecoration(
                                  hintText: 'Subject',
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: s.scoreCtrl,
                                keyboardType: TextInputType.number,
                                style: TextStyle(color: sc, fontSize: 14, fontWeight: FontWeight.w700),
                                decoration: const InputDecoration(
                                  hintText: '0-100',
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: TextField(
                                controller: s.creditCtrl,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                                decoration: const InputDecoration(
                                  hintText: '1',
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _removeSubject(i),
                              child: const Icon(Icons.remove_circle_outline, color: AppTheme.textMuted, size: 20),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 8),

                  // Add subject button
                  GestureDetector(
                    onTap: _addSubject,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4), style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(14),
                        color: AppTheme.primary.withValues(alpha: 0.05),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, color: AppTheme.primary, size: 20),
                          SizedBox(width: 8),
                          Text('Add Subject', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Grade scale
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Grade Scale', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
                        const SizedBox(height: 10),
                        _GradeRow('A+', '90-100', AppTheme.success),
                        _GradeRow('A', '85-89', AppTheme.success),
                        _GradeRow('B+', '80-84', const Color(0xFF00BFA5)),
                        _GradeRow('B', '75-79', const Color(0xFF00BFA5)),
                        _GradeRow('C+', '70-74', AppTheme.warning),
                        _GradeRow('C', '65-69', AppTheme.warning),
                        _GradeRow('D', '60-64', AppTheme.danger),
                        _GradeRow('F', 'Below 60', AppTheme.danger),
                      ],
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

class _Subject {
  final nameCtrl = TextEditingController();
  final scoreCtrl = TextEditingController();
  final creditCtrl = TextEditingController(text: '1');
}

class _GradeRow extends StatelessWidget {
  final String grade, range;
  final Color color;
  const _GradeRow(this.grade, this.range, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(grade, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 13)),
          ),
          Text(range, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
        ],
      ),
    );
  }
}
