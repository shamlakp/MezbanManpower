
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/url_helper.dart';

class RecruiterProfileScreen extends StatefulWidget {
  const RecruiterProfileScreen({super.key});

  @override
  State<RecruiterProfileScreen> createState() => _RecruiterProfileScreenState();
}

class _RecruiterProfileScreenState extends State<RecruiterProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _companyName = TextEditingController();
  final _website = TextEditingController();
  final _address = TextEditingController();
  final _recruiterName = TextEditingController();
  final _recruiterContact = TextEditingController();
  
  String? _companyId;
  PlatformFile? _pickedLogo;
  String? _existingLogoUrl;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final auth = context.read<AuthProvider>();
    final companies = await auth.fetchRecruiterProfile();
    
    if (mounted) {
      if (companies != null && companies.isNotEmpty) {
        final profile = companies.first;
        _companyName.text = profile['company_name'] ?? '';
        _website.text = profile['website'] ?? '';
        _address.text = profile['head_office_address'] ?? '';
        _recruiterName.text = profile['recruiter_name'] ?? '';
        _recruiterContact.text = profile['recruiter_contact'] ?? '';
        _existingLogoUrl = profile['logo'];
        _companyId = profile['id']?.toString();
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickLogo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.isNotEmpty) {
      setState(() => _pickedLogo = result.files.first);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    
    final data = {
      'company_name': _companyName.text,
      'website': _website.text,
      'head_office_address': _address.text,
      'recruiter_name': _recruiterName.text,
      'recruiter_contact': _recruiterContact.text,
    };

    if (_companyId != null) data['id'] = _companyId!;

    final success = await context.read<AuthProvider>().updateRecruiterProfile(data, _pickedLogo);

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Color(0xFF10B981)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.read<AuthProvider>().errorMessage ?? 'Failed to update')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF0EA5E9);
    
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Recruiter Profile', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _pickLogo,
                        child: Stack(
                          children: [
                            Container(
                              width: 100, height: 100,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(28),
                                child: _pickedLogo != null 
                                    ? (kIsWeb ? Image.memory(_pickedLogo!.bytes!, fit: BoxFit.cover) : const Icon(Icons.check, color: primary))
                                    : (_existingLogoUrl != null 
                                        ? Image.network(_getImageUrl(_existingLogoUrl!), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.business, size: 40, color: Color(0xFF94A3B8)))
                                        : const Icon(Icons.add_a_photo_outlined, size: 32, color: Color(0xFF94A3B8))),
                              ),
                            ),
                            Positioned(bottom: 0, right: 0, child: Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: primary, shape: BoxShape.circle), child: const Icon(Icons.edit, color: Colors.white, size: 14))),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildSectionTitle('Company Identity'),
                    _buildModernField(controller: _companyName, label: 'Company Name', icon: Icons.business_rounded),
                    const SizedBox(height: 16),
                    _buildModernField(controller: _website, label: 'Website URL', icon: Icons.language_rounded),
                    const SizedBox(height: 16),
                    _buildModernField(controller: _address, label: 'Head Office Address', icon: Icons.location_on_rounded, maxLines: 2),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Recruiter Information'),
                    _buildModernField(controller: _recruiterName, label: 'Your Full Name', icon: Icons.person_rounded),
                    const SizedBox(height: 16),
                    _buildModernField(controller: _recruiterContact, label: 'Contact Number', icon: Icons.phone_rounded, keyboardType: TextInputType.phone),
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
                            : const Text('Save Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
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

  Widget _buildModernField({required TextEditingController controller, required String label, required IconData icon, int maxLines = 1, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: (v) => v!.isEmpty ? 'Required' : null,
      style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
        prefixIcon: Icon(icon, color: const Color(0xFF0EA5E9), size: 20),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF0EA5E9), width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }

  String _getImageUrl(String path) {
    if (path.startsWith('http')) return path;
    return '${UrlHelper.getBaseUrl()}${path.startsWith('/') ? '' : '/'}$path';
  }
}
