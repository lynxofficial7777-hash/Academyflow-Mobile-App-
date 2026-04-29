import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../widgets/glass_card.dart';
import 'home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _deptController = TextEditingController();
  int _year = 1;
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _error;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _deptController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please fill in all required fields.');
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      setState(() => _error = 'Please enter a valid email address.');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }
    if (password != confirmPassword) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }

    setState(() { _loading = true; _error = null; });
    try {
      final result = await ApiService.signup(
        email: email,
        password: password,
        name: name,
        department: _deptController.text.trim().isEmpty ? null : _deptController.text.trim(),
        year: _year,
      );
      if (!mounted) return;
      if (result['access_token'] != null) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const HomeScreen(),
            transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      } else {
        setState(() => _error = result['detail'] ?? result['message'] ?? 'Signup failed');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = ApiService.getErrorMessage(e));
    }
    if (mounted) setState(() => _loading = false);
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscure = false,
    bool? obscureToggle,
    VoidCallback? onToggleObscure,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(
          color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600,
        )),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          textInputAction: textInputAction ?? TextInputAction.next,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppTheme.primary, size: 18),
            ),
            suffixIcon: obscureToggle != null
                ? IconButton(
                    icon: Icon(
                      obscureToggle ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppTheme.textMuted, size: 20,
                    ),
                    onPressed: onToggleObscure,
                  )
                : null,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0A0A), Color(0xFF1A0000), Color(0xFF2D0000)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Back button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.textSecondary, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: SlideTransition(
                    position: _slideAnim,
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: Column(
                        children: [
                          // Header
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppTheme.secondary, AppTheme.primary],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.secondary.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.person_add_rounded, size: 30, color: Colors.white),
                          ),
                          const SizedBox(height: 16),
                          Text('Create Account',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900, color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text('Join AcademyFlow to track your performance',
                            style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                          ),
                          const SizedBox(height: 28),

                          // Form
                          GlassCard(
                            padding: const EdgeInsets.all(22),
                            borderColor: AppTheme.secondary.withValues(alpha: 0.15),
                            child: Column(
                              children: [
                                _buildField(
                                  controller: _nameController,
                                  label: 'Full Name *',
                                  hint: 'Enter your name',
                                  icon: Icons.person_outlined,
                                ),
                                const SizedBox(height: 16),
                                _buildField(
                                  controller: _emailController,
                                  label: 'Email *',
                                  hint: 'you@example.com',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 16),
                                _buildField(
                                  controller: _passwordController,
                                  label: 'Password * (min 6 chars)',
                                  hint: 'Create a password',
                                  icon: Icons.lock_outlined,
                                  obscure: _obscurePassword,
                                  obscureToggle: _obscurePassword,
                                  onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                                const SizedBox(height: 16),
                                _buildField(
                                  controller: _confirmPasswordController,
                                  label: 'Confirm Password *',
                                  hint: 'Re-enter your password',
                                  icon: Icons.lock_outlined,
                                  obscure: _obscureConfirm,
                                  obscureToggle: _obscureConfirm,
                                  onToggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm),
                                ),
                                const SizedBox(height: 16),
                                _buildField(
                                  controller: _deptController,
                                  label: 'Department (optional)',
                                  hint: 'e.g. Computer Science',
                                  icon: Icons.school_outlined,
                                ),
                                const SizedBox(height: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Year', style: TextStyle(
                                      color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600,
                                    )),
                                    const SizedBox(height: 6),
                                    DropdownButtonFormField<int>(
                                      value: _year,
                                      dropdownColor: AppTheme.bgMid,
                                      style: const TextStyle(color: AppTheme.textPrimary),
                                      decoration: InputDecoration(
                                        prefixIcon: Container(
                                          margin: const EdgeInsets.all(10),
                                          padding: const EdgeInsets.all(7),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primary.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(Icons.calendar_today, color: AppTheme.primary, size: 18),
                                        ),
                                      ),
                                      items: [1, 2, 3, 4].map((y) =>
                                        DropdownMenuItem(value: y, child: Text('Year $y')),
                                      ).toList(),
                                      onChanged: (v) => setState(() => _year = v ?? 1),
                                    ),
                                  ],
                                ),

                                if (_error != null) ...[
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppTheme.danger.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: AppTheme.danger.withValues(alpha: 0.3)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.error_outline, color: AppTheme.danger, size: 18),
                                        const SizedBox(width: 10),
                                        Expanded(child: Text(_error!,
                                          style: const TextStyle(color: AppTheme.danger, fontSize: 13),
                                        )),
                                      ],
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: _loading ? null : _signup,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.secondary,
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor: AppTheme.secondary.withValues(alpha: 0.5),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                      elevation: 0,
                                    ),
                                    child: _loading
                                        ? const SizedBox(height: 22, width: 22,
                                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                                        : const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text('Create Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                                              SizedBox(width: 8),
                                              Icon(Icons.arrow_forward_rounded, size: 20),
                                            ],
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Already have an account? ',
                                style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: const Text('Sign In',
                                  style: TextStyle(color: AppTheme.primary, fontSize: 14, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
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
