
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ApplicantProfileScreen extends StatefulWidget {
  const ApplicantProfileScreen({super.key});

  @override
  State<ApplicantProfileScreen> createState() => _ApplicantProfileScreenState();
}

class _ApplicantProfileScreenState extends State<ApplicantProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _phone = TextEditingController();
  final _bio = TextEditingController();
  final _skills = TextEditingController();
  PlatformFile? _resumeFile;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final auth = context.read<AuthProvider>();
    _fullName.text = auth.userData?['full_name'] ?? '';
    
    final profile = await auth.fetchApplicantProfile();
    if (profile != null) {
      _phone.text = profile['phone'] ?? '';
      _bio.text = profile['bio'] ?? '';
      _skills.text = profile['skills'] ?? '';
      if (mounted) setState(() {});
    }
  }

  Future<void> _pickResume() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _resumeFile = result.files.first);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    
    final data = {
      'full_name': _fullName.text,
      'phone': _phone.text,
      'bio': _bio.text,
      'skills': _skills.text,
    };
    
    final success = await context.read<AuthProvider>().updateApplicantProfile(data, _resumeFile);
    
    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Color(0xFF10B981)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.read<AuthProvider>().errorMessage ?? 'Failed to update profile')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF6366F1);
    
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Update Profile', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: primary, width: 2)),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color(0xFFF1F5F9),
                        child: Text(
                          _fullName.text.isNotEmpty ? _fullName.text[0].toUpperCase() : '?',
                          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: primary),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: primary, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              _buildSectionTitle('Basic Information'),
              _buildModernField(controller: _fullName, label: 'Full Name', icon: Icons.person_outline_rounded),
              const SizedBox(height: 16),
              _buildModernField(controller: _phone, label: 'Phone Number', icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
              const SizedBox(height: 32),
              _buildSectionTitle('Professional Bio'),
              _buildModernField(controller: _bio, label: 'Tell us about yourself', icon: Icons.info_outline_rounded, maxLines: 4),
              const SizedBox(height: 32),
              _buildSectionTitle('Skills & Expertise'),
              _buildModernField(controller: _skills, label: 'Skills (e.g. Flutter, Design)', icon: Icons.code_rounded),
              const SizedBox(height: 32),
              _buildSectionTitle('Resume'),
              GestureDetector(
                onTap: _pickResume,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.file_present_rounded, color: primary),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _resumeFile?.name ?? 'Upload New Resume',
                          style: TextStyle(
                            color: _resumeFile != null ? const Color(0xFF1E293B) : const Color(0xFF94A3B8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Icon(Icons.cloud_upload_outlined, color: Color(0xFF94A3B8)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isSaving
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 1),
      ),
    );
  }

  Widget _buildModernField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
        prefixIcon: Icon(icon, color: const Color(0xFF6366F1), size: 20),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }
}
