
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../constants/colors.dart';
import '../utils/url_helper.dart';
import '../widgets/glass_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textformfield.dart';

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
  PlatformFile? _imageFile;
  String? _profileImageUrl;
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
      _fullName.text = profile['full_name'] ?? '';
      _phone.text = profile['phone'] ?? '';
      _bio.text = profile['bio'] ?? '';
      _skills.text = profile['skills'] ?? '';
      _profileImageUrl = profile['profile_image'];
      debugPrint('Profile Loaded: Image URL = $_profileImageUrl');
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

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _imageFile = result.files.first);
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
    
    final success = await context.read<AuthProvider>().updateApplicantProfile(data, _resumeFile, _imageFile);
    
    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: SuccessColor.c500));
        setState(() {
          _imageFile = null;
          _resumeFile = null;
        });
        PaintingBinding.instance.imageCache.clear();
        await _loadProfile(); // Refresh image and data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.read<AuthProvider>().errorMessage ?? 'Failed to update profile')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = BrandColor.c500;
    
    return Scaffold(
      backgroundColor: NeutralColor.c50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: NeutralColor.c900, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Update Profile', style: TextStyle(color: NeutralColor.c900, fontWeight: FontWeight.w900)),
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
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: primary, width: 2)),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: NeutralColor.c100,
                          backgroundImage: _imageFile == null && _profileImageUrl != null
                              ? NetworkImage(UrlHelper.resolveMediaUrl(_profileImageUrl))
                              : null,
                          child: _imageFile != null
                              ? ClipOval(
                                  child: kIsWeb
                                      ? Image.memory(
                                          _imageFile!.bytes!,
                                          width: 100, height: 100,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(
                                          File(_imageFile!.path!),
                                          width: 100, height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                )
                              : (_profileImageUrl == null
                                  ? Text(
                                      _fullName.text.isNotEmpty ? _fullName.text[0].toUpperCase() : '?',
                                      style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: primary),
                                    )
                                  : null),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: primary, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              _buildSectionTitle('Basic Information'),
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildModernField(controller: _fullName, label: 'Full Name', icon: Icons.person_outline_rounded),
                    const SizedBox(height: 16),
                    _buildModernField(controller: _phone, label: 'Phone Number', icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('Professional Bio'),
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: _buildModernField(controller: _bio, label: 'Tell us about yourself', icon: Icons.info_outline_rounded, maxLines: 4),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('Skills & Expertise'),
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: _buildModernField(controller: _skills, label: 'Skills (e.g. Flutter, Design)', icon: Icons.code_rounded),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('Resume'),
              GestureDetector(
                onTap: _pickResume,
                child: GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(Icons.file_present_rounded, color: primary),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _resumeFile?.name ?? 'Upload New Resume',
                          style: TextStyle(
                            color: _resumeFile != null ? NeutralColor.c900 : NeutralColor.c400,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Icon(Icons.cloud_upload_outlined, color: NeutralColor.c400),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: _isSaving
                    ? const Center(child: CircularProgressIndicator())
                    : CustomButton(
                        onPressed: _save,
                        buttonBgColor: primary,
                        fontColor: NeutralColor.c50,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        text: 'Save Changes',
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: NeutralColor.c50),
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
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: NeutralColor.c400, letterSpacing: 1),
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
    return CustomTextFormField(
      size: MediaQuery.of(context).size,
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(fontWeight: FontWeight.w600, color: NeutralColor.c900),
      hintText: label,
      hintStyle: const TextStyle(color: NeutralColor.c400, fontWeight: FontWeight.w500),
      prefixIcon: Icon(icon, color: BrandColor.c500, size: 20),
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: NeutralColor.c200)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: BrandColor.c500, width: 2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }
}
