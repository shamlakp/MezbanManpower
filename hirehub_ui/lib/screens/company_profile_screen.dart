import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/url_helper.dart';
import '../constants/colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textformfield.dart';

class CompanyProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? company;
  const CompanyProfileScreen({super.key, this.company});

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _companyNameController = TextEditingController();
  final _websiteController = TextEditingController();
  final _addressController = TextEditingController();
  final _recruiterNameController = TextEditingController();
  final _recruiterContactController = TextEditingController();
  
  String? _companyId;
  PlatformFile? _pickedFile;
  String? _existingLogoUrl;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    _recruiterNameController.dispose();
    _recruiterContactController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final profile = widget.company;

    if (mounted) {
      if (profile != null) {
        _companyNameController.text = (profile['company_name'] as String?) ?? '';
        _websiteController.text = (profile['website'] as String?) ?? '';
        _addressController.text = (profile['head_office_address'] as String?) ?? '';
        _recruiterNameController.text = (profile['recruiter_name'] as String?) ?? '';
        _recruiterContactController.text = (profile['recruiter_contact'] as String?) ?? '';
        _existingLogoUrl = profile['logo'] as String?;
        _companyId = profile['id']?.toString();
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickLogo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true); 
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _pickedFile = result.files.first;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    final data = {
      'company_name': _companyNameController.text,
      'website': _websiteController.text,
      'head_office_address': _addressController.text,
      'recruiter_name': _recruiterNameController.text,
      'recruiter_contact': _recruiterContactController.text,
    };

    if (_companyId != null) {
      data['id'] = _companyId!;
    }

    final success = await context.read<AuthProvider>().updateRecruiterProfile(
      data,
      _pickedFile,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved successfully')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.read<AuthProvider>().errorMessage ?? 'Failed to save profile')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeutralColor.c50,
      appBar: AppBar(
        title: Text('Company Profile', style: TextStyle(color: NeutralColor.c900)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: NeutralColor.c900),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
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
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _pickedFile != null
                                ? (kIsWeb && _pickedFile!.bytes != null 
                                    ? Image.memory(_pickedFile!.bytes!, fit: BoxFit.cover) 
                                    : const Icon(Icons.check, color: SuccessColor.c500))
                                : (_existingLogoUrl != null && _existingLogoUrl!.isNotEmpty)
                                    ? Image.network(
                                        _getImageUrl(_existingLogoUrl!),
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const Icon(Icons.business, size: 40, color: Colors.grey),
                                      )
                                    : const Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Center(child: Text('Tap to change logo', style: TextStyle(color: Colors.grey, fontSize: 12))),
                    
                    const SizedBox(height: 32),
                    _buildSectionTitle('Company Information'),
                    _buildField(controller: _companyNameController, label: 'Company Name', icon: Icons.business),
                    const SizedBox(height: 16),
                    _buildField(controller: _websiteController, label: 'Website', icon: Icons.language),
                    const SizedBox(height: 16),
                    _buildField(controller: _addressController, label: 'Head Office Address', icon: Icons.location_on, maxLines: 2),

                    const SizedBox(height: 32),
                    _buildSectionTitle('Recruiter Details'),
                    _buildField(controller: _recruiterNameController, label: 'Recruiter Name', icon: Icons.person),
                    const SizedBox(height: 16),
                    _buildField(controller: _recruiterContactController, label: 'Contact Number', icon: Icons.phone),

                    const SizedBox(height: 40),
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        return SizedBox(
                          width: double.infinity,
                          child: auth.isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : CustomButton(
                                  onPressed: _save,
                                  buttonBgColor: BrandColor.c500,
                                  fontColor: NeutralColor.c50,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  text: 'Save Profile',
                                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: NeutralColor.c900),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return CustomTextFormField(
      size: MediaQuery.of(context).size,
      controller: controller,
      hintText: label,
      hintStyle: TextStyle(color: NeutralColor.c500, fontWeight: FontWeight.w500),
      prefixIcon: Icon(icon, size: 20, color: BrandColor.c500),
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: BrandColor.c500, width: 1.5),
      ),
      maxLines: maxLines,
      validator: (value) => value!.isEmpty ? 'This field is required' : null,
    );
  }

  String _getImageUrl(String imagePath) {
    if (imagePath.startsWith('http')) return imagePath;
    final path = imagePath.startsWith('/') ? imagePath : '/$imagePath';
    return '${UrlHelper.getBaseUrl()}$path';
  }
}
