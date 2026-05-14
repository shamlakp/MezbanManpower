import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../constants/colors.dart';
import 'dashboard_screen.dart';
import 'applicant_dashboard_screen.dart';
import 'register_screen.dart';
import 'applicant_register_screen.dart';
import '../widgets/mezban_logo.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textformfield.dart';
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
              MaterialPageRoute(builder: (_) => const ApplicantDashboardScreen()),
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
      backgroundColor: NeutralColor.c50,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: NeutralColor.c300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Join HireHub',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: NeutralColor.c900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose how you want to use the platform',
              style: TextStyle(color: NeutralColor.c600),
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
    );
  }

  Widget _buildRoleOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: NeutralColor.c100,
          border: Border.all(color: NeutralColor.c200),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: BrandColor.c50,
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
                      color: NeutralColor.c900,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: NeutralColor.c600, fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: NeutralColor.c500),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeutralColor.c50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: NeutralColor.c900, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // ── Logo icon ─────────────────────────────────────
              const Center(
                child: MezbanLogo(fontSize: 48, showText: false),
              ),
              const SizedBox(height: 40),

              // ── Heading ───────────────────────────────────────
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 32, color: NeutralColor.c900, letterSpacing: -1),
                  children: [
                    const TextSpan(text: 'Welcome ', style: TextStyle(fontWeight: FontWeight.w700)),
                    TextSpan(text: 'Back', style: TextStyle(color: NeutralColor.c500, fontWeight: FontWeight.w400)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to access your dashboard.',
                style: TextStyle(
                  fontSize: 16,
                  color: NeutralColor.c600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 48),

              // ── Form ──────────────────────────────────────────
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _usernameController,
                      hint: 'Username',
                      icon: Icons.alternate_email_rounded,
                      validator: (v) => v!.isEmpty ? 'Please enter username' : null,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _passwordController,
                      hint: 'Password',
                      icon: Icons.lock_outline_rounded,
                      isPassword: true,
                      validator: (v) => v!.isEmpty ? 'Please enter password' : null,
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(color: BrandColor.c500, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Sign In Button ─────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: Consumer<AuthProvider>(
                        builder: (context, auth, _) => CustomButton(
                          onPressed: auth.isLoading ? null : _submit,
                          text: 'Sign In',
                          buttonBgColor: BrandColor.c500,
                          fontColor: NeutralColor.c50,
                          elevation: 0,
                          height: 56,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: NeutralColor.c50),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // ── Register link ──────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t have an account? ',
                          style: TextStyle(color: NeutralColor.c600),
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
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return CustomTextFormField(
      size: MediaQuery.of(context).size,
      controller: controller,
      obscureText: isPassword && _obscurePassword,
      validator: validator,
      style: TextStyle(fontWeight: FontWeight.w600, color: NeutralColor.c900),
      hintText: hint,
      hintStyle: TextStyle(color: NeutralColor.c500, fontWeight: FontWeight.w500),
      prefixIcon: Icon(icon, color: BrandColor.c500, size: 20),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: NeutralColor.c500,
                size: 20,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            )
          : null,
      fillColor: NeutralColor.c100,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: NeutralColor.c200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: BrandColor.c500, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }
}
