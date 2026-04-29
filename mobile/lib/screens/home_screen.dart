import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../widgets/glass_card.dart';
import 'predict_screen.dart';
import 'history_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F172A), Color(0xFF1E1B4B), Color(0xFF312E81)],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.primary, AppTheme.secondary],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.insights_rounded, size: 24, color: Colors.white),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_getGreeting(),
                                style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                              const Text('AcademyFlow',
                                style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.cardBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.cardBorder),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.logout_rounded, color: AppTheme.textMuted, size: 20),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: AppTheme.bgMid,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  title: const Text('Sign Out', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
                                  content: const Text('Are you sure you want to sign out?', style: TextStyle(color: AppTheme.textSecondary)),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, false),
                                      child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text('Sign Out', style: TextStyle(color: AppTheme.danger, fontWeight: FontWeight.w700)),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true && context.mounted) {
                                await ApiService.logout();
                                if (context.mounted) {
                                  Navigator.pushReplacement(context,
                                    PageRouteBuilder(
                                      pageBuilder: (_, __, ___) => const LoginScreen(),
                                      transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
                                      transitionDuration: const Duration(milliseconds: 400),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 28)),

                // Hero CTA card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.primary.withValues(alpha: 0.25),
                            AppTheme.secondary.withValues(alpha: 0.15),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.25)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [AppTheme.primary, AppTheme.secondary],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primary.withValues(alpha: 0.3),
                                        blurRadius: 16,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.auto_awesome, size: 26, color: Colors.white),
                                ),
                                const SizedBox(width: 16),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Predict Performance',
                                        style: TextStyle(
                                          fontSize: 19, fontWeight: FontWeight.w800,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text('Get AI-powered insights & a personalized study plan',
                                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () => Navigator.push(context,
                                  PageRouteBuilder(
                                    pageBuilder: (_, __, ___) => const PredictScreen(),
                                    transitionsBuilder: (_, a, __, child) =>
                                      SlideTransition(
                                        position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
                                          .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
                                        child: FadeTransition(opacity: a, child: child),
                                      ),
                                    transitionDuration: const Duration(milliseconds: 350),
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  elevation: 0,
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.play_arrow_rounded, size: 22),
                                    SizedBox(width: 8),
                                    Text('Start Prediction',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 28)),

                // Features section header
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text('Explore Features',
                      style: TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary, letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 14)),

                // Feature cards grid
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.15,
                    children: [
                      _FeatureCard(
                        icon: Icons.analytics_rounded,
                        title: 'Performance\nAnalysis',
                        subtitle: 'AI score prediction',
                        color: AppTheme.primary,
                        onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const PredictScreen())),
                      ),
                      _FeatureCard(
                        icon: Icons.flag_rounded,
                        title: 'Goal\nTracker',
                        subtitle: 'Set & track goals',
                        color: AppTheme.secondary,
                        onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const PredictScreen())),
                      ),
                      _FeatureCard(
                        icon: Icons.people_rounded,
                        title: 'Peer\nComparison',
                        subtitle: 'Compare with class',
                        color: AppTheme.success,
                        onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const PredictScreen())),
                      ),
                      _FeatureCard(
                        icon: Icons.history_rounded,
                        title: 'Prediction\nHistory',
                        subtitle: 'Past results',
                        color: AppTheme.warning,
                        onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const HistoryScreen())),
                      ),
                    ],
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 28)),

                // Stats row
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      borderColor: AppTheme.accent.withValues(alpha: 0.2),
                      child: Row(
                        children: [
                          _StatItem(icon: Icons.speed_rounded, label: 'Fast', value: 'Prediction', color: AppTheme.accent),
                          Container(width: 1, height: 36, color: AppTheme.cardBorder),
                          _StatItem(icon: Icons.psychology_rounded, label: 'ML', value: 'Powered', color: AppTheme.secondary),
                          Container(width: 1, height: 36, color: AppTheme.cardBorder),
                          _StatItem(icon: Icons.shield_rounded, label: '99%+', value: 'Accuracy', color: AppTheme.success),
                        ],
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedGlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      borderColor: color.withValues(alpha: 0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(subtitle,
                style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 14)),
          Text(value, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
        ],
      ),
    );
  }
}
