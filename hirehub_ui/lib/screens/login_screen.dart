import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../providers/auth_provider.dart';
import '../constants/colors.dart';
import 'dashboard_screen.dart';
import 'applicant_dashboard_screen.dart';
import 'register_screen.dart';
import 'applicant_register_screen.dart';
import '../widgets/mezban_logo.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textformfield.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final success = await context.read<AuthProvider>().login(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Login Successful!'),
              backgroundColor: SuccessColor.c500,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
          final auth = context.read<AuthProvider>();
          final rawUserType = (auth.userData?['user_type'] ?? auth.userData?['role'] ?? 'applicant')
              .toString()
              .toLowerCase();
          if (rawUserType.contains('applicant')) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => ApplicantDashboardScreen(
                onBrowseJobs: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const DashboardScreen()),
                  );
                },
              )),
            );
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.read<AuthProvider>().errorMessage ?? 'Login Failed'),
              backgroundColor: DangerColor.c500,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    }
  }

  void _showRegisterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          padding: const EdgeInsets.fromLTRB(32, 20, 32, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: NeutralColor.c400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Join Mezban Manpower',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).colorScheme.onBackground,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose how you want to use the platform',
                style: TextStyle(color: NeutralColor.c500),
              ),
              const SizedBox(height: 32),
              _buildRoleOption(
                icon: Icons.person_search_rounded,
                title: 'I am a Jobseeker',
                subtitle: 'Find roles and manage applications',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ApplicantRegisterScreen()));
                },
              ),
              const SizedBox(height: 16),
              _buildRoleOption(
                icon: Icons.business_rounded,
                title: 'I am a Recruiter',
                subtitle: 'Post jobs and hire top talent',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : NeutralColor.c200),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: BrandColor.c500.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: BrandColor.c500),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: isDark ? Colors.white : NeutralColor.c900,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: isDark ? Colors.white60 : NeutralColor.c600, fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: BrandColor.c500),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark 
                    ? [const Color(0xFF0F172A), const Color(0xFF1E1B4B)] 
                    : [const Color(0xFFE0E7FF), const Color(0xFFF8FAFC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          
          // Decorative Blurred Orbs
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF06B6D4).withValues(alpha: 0.3),
              ),
            ),
          ),
          
          // Blur Layer over Background
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
            child: Container(color: Colors.transparent),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded, color: Theme.of(context).colorScheme.onBackground, size: 20),
                      onPressed: () => Navigator.pop(context),
                      style: IconButton.styleFrom(
                        backgroundColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Logo icon ─────────────────────────────────────
                  const Center(
                    child: MezbanLogo(fontSize: 48, showText: false),
                  ),
                  const SizedBox(height: 40),

                  // ── Glassmorphism Card ──────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // ── Heading ───────────────────────────────────────
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 28, 
                              color: Theme.of(context).colorScheme.onBackground, 
                              letterSpacing: -1,
                              fontFamily: 'Inter',
                            ),
                            children: [
                              const TextSpan(text: 'Welcome ', style: TextStyle(fontWeight: FontWeight.w800)),
                              TextSpan(text: 'Back', style: TextStyle(color: BrandColor.c500, fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sign in to access your dashboard.',
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark ? Colors.white60 : NeutralColor.c600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // ── Form ──────────────────────────────────────────
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _buildTextField(
                                controller: _usernameController,
                                hint: 'Mobile Number or Username',
                                icon: Icons.person_outline_rounded,
                                validator: (v) => v!.isEmpty ? 'Please enter mobile number or username' : null,
                                isDark: isDark,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _passwordController,
                                hint: 'Password',
                                icon: Icons.lock_outline_rounded,
                                isPassword: true,
                                validator: (v) => v!.isEmpty ? 'Please enter password' : null,
                                isDark: isDark,
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                                    );
                                  },
                                  child: Text(
                                    'Forgot Password?',
                                    style: TextStyle(color: BrandColor.c500, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // ── Sign In Button ─────────────────────────
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: Consumer<AuthProvider>(
                                  builder: (context, auth, _) => CustomButton(
                                    onPressed: auth.isLoading ? null : _submit,
                                    text: 'Sign In',
                                    buttonBgColor: BrandColor.c500,
                                    fontColor: Colors.white,
                                    elevation: 5,
                                    height: 56,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),

                              // ── Register link ──────────────────────────
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Don\'t have an account? ',
                                    style: TextStyle(color: isDark ? Colors.white70 : NeutralColor.c600),
                                  ),
                                  GestureDetector(
                                    onTap: _showRegisterDialog,
                                    child: Text(
                                      'Register',
                                      style: TextStyle(
                                        color: BrandColor.c500,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    required bool isDark,
    String? Function(String?)? validator,
  }) {
    return CustomTextFormField(
      size: MediaQuery.of(context).size,
      controller: controller,
      obscureText: isPassword && _obscurePassword,
      validator: validator,
      style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onBackground),
      hintText: hint,
      hintStyle: TextStyle(color: isDark ? Colors.white38 : NeutralColor.c500, fontWeight: FontWeight.w500),
      prefixIcon: Icon(icon, color: BrandColor.c500, size: 20),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: isDark ? Colors.white54 : NeutralColor.c500,
                size: 20,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            )
          : null,
      fillColor: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.5),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: BrandColor.c500, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }
}
