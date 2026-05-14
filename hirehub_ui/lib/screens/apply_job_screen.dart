
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hirehub_ui/models/job_post.dart';
import 'package:hirehub_ui/services/api_service.dart';
import 'package:hirehub_ui/utils/url_helper.dart';
import '../constants/colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/success_dialog.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textformfield.dart';

class ApplyJobScreen extends StatefulWidget {
  final JobPost job;
  const ApplyJobScreen({super.key, required this.job});

  @override
  State<ApplyJobScreen> createState() => _ApplyJobScreenState();
}

class _ApplyJobScreenState extends State<ApplyJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _coverLetterController = TextEditingController();

  PlatformFile? _resumeFile;
  bool _isLoading = false;

  Future<void> _pickResume() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _resumeFile = result.files.first;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _coverLetterController.dispose();
    super.dispose();
  }

  // Removed _isLoading since it's now at the top of State

  Future<void> _submitApplication() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final apiService = ApiService();
        await apiService.applyForJob(
          widget.job.id,
          notes: _coverLetterController.text,
          resumeFile: _resumeFile,
        );

        if (mounted) {
          showDialog(
            context: context,
            builder: (_) => const SuccessDialog(message: 'Your application has been sent successfully!'),
          ).then((_) => Navigator.pop(context));
        }
      } catch (e) {
        if (mounted) {
          String errorMessage = 'Failed to submit application.';
          if (e is DioException && e.response?.data != null) {
            final data = e.response!.data;
            if (data is List && data.isNotEmpty) {
              errorMessage = data[0].toString();
            } else if (data is Map && data.containsKey('non_field_errors')) {
               errorMessage = data['non_field_errors'][0].toString();
            } else if (data is Map) {
               errorMessage = data.values.first.toString();
            }
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeutralColor.c50,
      appBar: AppBar(
        title: Text('Apply for Job', style: TextStyle(color: NeutralColor.c900, fontWeight: FontWeight.w900)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: NeutralColor.c900, onPressed: () => Navigator.pop(context)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Job Summary Card
              GlassCard(
                padding: const EdgeInsets.all(20),
                opacity: 0.8,
                color: BrandColor.c50,
                child: Row(
                  children: [
                     Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: (widget.job.image != null && widget.job.image!.isNotEmpty)
                            ? Image.network(
                                _getImageUrl(widget.job.image!),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.business, size: 24, color: NeutralColor.c400),
                              )
                            : const Icon(Icons.business, size: 24, color: NeutralColor.c400),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.job.position,
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: NeutralColor.c900),
                          ),
                          Text(widget.job.companyName, style: const TextStyle(color: NeutralColor.c600, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              const Text(
                'Personal Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              CustomTextFormField(
                size: MediaQuery.of(context).size,
                controller: _nameController,
                hintText: 'Full Name',
                validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 16),
              
              CustomTextFormField(
                size: MediaQuery.of(context).size,
                controller: _emailController,
                hintText: 'Email Address',
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.contains('@') ? null : 'Please enter a valid email',
              ),
              const SizedBox(height: 16),

              CustomTextFormField(
                size: MediaQuery.of(context).size,
                controller: _phoneController,
                hintText: 'Phone Number',
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'Please enter your phone number' : null,
              ),

              const SizedBox(height: 32),
              const Text(
                'Additional Info',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Resume Upload Placeholder
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: NeutralColor.c200),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.cloud_upload_outlined, size: 40, color: BrandColor.c500),
                    const SizedBox(height: 12),
                    const Text('Upload your Resume/CV', style: TextStyle(fontWeight: FontWeight.w700, color: NeutralColor.c900)),
                    const SizedBox(height: 4),
                    const Text(
                      'Supported formats: PDF, DOCX',
                      style: TextStyle(fontSize: 12, color: NeutralColor.c500),
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton(
                      onPressed: _pickResume,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: BrandColor.c500),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(_resumeFile == null ? 'Browse Files' : 'Change File', style: const TextStyle(color: BrandColor.c500)),
                    ),
                    if (_resumeFile != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: SuccessColor.c50, borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_rounded, color: SuccessColor.c500, size: 16),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                _resumeFile!.name,
                                style: const TextStyle(fontWeight: FontWeight.w700, color: SuccessColor.c700),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),
              CustomTextFormField(
                size: MediaQuery.of(context).size,
                controller: _coverLetterController,
                hintText: 'Cover Letter (Optional)',
                maxLines: 5,
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: _isLoading 
                    ? const Center(child: CircularProgressIndicator())
                    : CustomButton(
                        onPressed: _submitApplication,
                        buttonBgColor: BrandColor.c500,
                        fontColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                        text: 'Submit Application',
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: NeutralColor.c500, fontWeight: FontWeight.w500),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: BrandColor.c500, width: 2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }

  String _getImageUrl(String imagePath) {
    return UrlHelper.resolveMediaUrl(imagePath);
  }
}
