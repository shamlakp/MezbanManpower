import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../constants/colors.dart';
import 'login_screen.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textformfield.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username      = TextEditingController();
  final _mobileNumber  = TextEditingController();
  final _password      = TextEditingController();
  final _confirm       = TextEditingController();
  final _otpController = TextEditingController();

  bool _otpSent     = false;
  bool _otpVerified = false;
  bool _obscurePass = true;
  bool _obscureConf = true;

  // ── Step index for the stepper indicator ──────────────────
  int get _step => !_otpSent ? 0 : (!_otpVerified ? 1 : 2);

  Future<void> _handleAction() async {
    if (!_formKey.currentState!.validate()) return;
    final auth         = context.read<AuthProvider>();
    final mobileNumber = _mobileNumber.text.trim();

    if (!_otpSent) {
      final ok = await auth.sendOTP(mobileNumber);
      if (!mounted) return;
      if (ok) {
        setState(() => _otpSent = true);
        if (auth.lastOtp != null) _otpController.text = auth.lastOtp!;
        _snack(auth.lastOtp != null ? 'OTP: ${auth.lastOtp}' : 'OTP sent to your mobile number!', SuccessColor.c500);
      } else {
        _snack(auth.errorMessage ?? 'Failed to send OTP', DangerColor.c500);
      }
      return;
    }

    if (!_otpVerified) {
      final ok = await auth.verifyOTP(mobileNumber, _otpController.text.trim());
      if (!mounted) return;
      if (ok) {
        setState(() => _otpVerified = true);
        _snack('Mobile number verified! Set your password.', SuccessColor.c500);
      } else {
        _snack(auth.errorMessage ?? 'Invalid OTP', DangerColor.c500);
      }
      return;
    }

    final ok = await auth.registerRecruiter({
      'username': _username.text.trim(),
      'mobile_number': mobileNumber,
      'password': _password.text.trim(),
    });
    if (!mounted) return;
    if (ok) {
      _snack('Registration successful! Please log in.', SuccessColor.c500);
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    } else {
      _snack(auth.errorMessage ?? 'Registration failed', DangerColor.c500);
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
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
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // ── Header ────────────────────────────────────────
              Center(
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: BrandColor.c50,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: BrandColor.c200.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
                  ),
                  child: Icon(Icons.business_rounded, size: 42, color: BrandColor.c500),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 26, color: NeutralColor.c900, letterSpacing: -0.5),
                    children: [
                      const TextSpan(text: 'Recruiter ', style: TextStyle(fontWeight: FontWeight.w700)),
                      TextSpan(text: 'Registration', style: TextStyle(color: NeutralColor.c500, fontWeight: FontWeight.w400)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text('Post jobs and find the best talent',
                    style: TextStyle(fontSize: 14, color: NeutralColor.c600)),
              ),
              const SizedBox(height: 28),

              // ── Step indicator ────────────────────────────────
              _StepIndicator(step: _step, labels: const ['Details', 'Verify OTP', 'Password']),
              const SizedBox(height: 32),

              // ── Form ──────────────────────────────────────────
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildField(controller: _username, label: 'Username', icon: Icons.person_outline_rounded,
                        enabled: !_otpVerified, validator: (v) => v!.isEmpty ? 'Required' : null),
                    const SizedBox(height: 16),
                    _buildField(controller: _mobileNumber, label: 'Mobile Number', icon: Icons.phone_android_rounded,
                        enabled: !_otpSent, keyboardType: TextInputType.phone,
                        validator: (v) => v!.isEmpty ? 'Required' : null),

                    if (_otpSent && !_otpVerified) ...[
                      const SizedBox(height: 16),
                      _buildField(controller: _otpController, label: 'Enter 6-digit OTP', icon: Icons.pin_rounded,
                          keyboardType: TextInputType.number,
                          validator: (v) => v!.isEmpty ? 'Required' : null),
                    ],

                    if (_otpVerified) ...[
                      const SizedBox(height: 16),
                      _buildField(controller: _password, label: 'Password', icon: Icons.lock_outline_rounded,
                          isPassword: true, obscure: _obscurePass,
                          onToggle: () => setState(() => _obscurePass = !_obscurePass),
                          validator: (v) => v!.length < 6 ? 'Min 6 characters' : null),
                      const SizedBox(height: 16),
                      _buildField(controller: _confirm, label: 'Confirm Password', icon: Icons.lock_outline_rounded,
                          isPassword: true, obscure: _obscureConf,
                          onToggle: () => setState(() => _obscureConf = !_obscureConf),
                          validator: (v) => v != _password.text ? 'Passwords do not match' : null),
                    ],

                    const SizedBox(height: 32),
                    Consumer<AuthProvider>(
                      builder: (_, auth, __) => SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: auth.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : CustomButton(
                                onPressed: _handleAction,
                                buttonBgColor: BrandColor.c500,
                                fontColor: NeutralColor.c50,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                text: !_otpSent ? 'Send OTP' : (!_otpVerified ? 'Verify OTP' : 'Create Account'),
                                textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: NeutralColor.c50),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Already have an account? ', style: TextStyle(color: NeutralColor.c600)),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                          child: Text('Sign In', style: TextStyle(color: BrandColor.c500, fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggle,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return CustomTextFormField(
      size: MediaQuery.of(context).size,
      controller: controller,
      readOnly: !enabled,
      obscureText: isPassword && obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(fontWeight: FontWeight.w600, color: enabled ? NeutralColor.c900 : NeutralColor.c500),
      hintText: label,
      hintStyle: TextStyle(color: NeutralColor.c500, fontWeight: FontWeight.w500),
      prefixIcon: Icon(icon, color: enabled ? BrandColor.c500 : NeutralColor.c400, size: 20),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: NeutralColor.c500, size: 20),
              onPressed: onToggle,
            )
          : null,
      fillColor: enabled ? NeutralColor.c100 : NeutralColor.c200,
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: NeutralColor.c200)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: BrandColor.c500, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    );
  }
}

// ── Shared step indicator widget ──────────────────────────────
class _StepIndicator extends StatelessWidget {
  final int step;
  final List<String> labels;
  const _StepIndicator({required this.step, required this.labels});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(labels.length * 2 - 1, (i) {
        if (i.isOdd) {
          final lineStep = i ~/ 2;
          return Expanded(
            child: Container(
              height: 2,
              color: lineStep < step ? BrandColor.c500 : NeutralColor.c200,
            ),
          );
        }
        final idx = i ~/ 2;
        final done = idx < step;
        final active = idx == step;
        return Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 32, height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? BrandColor.c500 : (active ? BrandColor.c50 : NeutralColor.c200),
                border: Border.all(color: active ? BrandColor.c500 : Colors.transparent, width: 2),
              ),
              child: Center(
                child: done
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                    : Text('${idx + 1}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                        color: active ? BrandColor.c500 : NeutralColor.c600)),
              ),
            ),
            const SizedBox(height: 4),
            Text(labels[idx], style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                color: active ? BrandColor.c500 : NeutralColor.c500)),
          ],
        );
      }),
    );
  }
}
