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
  final _phone = TextEditingController();
  final _bio = TextEditingController();
  final _skills = TextEditingController();
  PlatformFile? _resumeFile;

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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final data = {
      'phone': _phone.text,
      'bio': _bio.text,
      'skills': _skills.text,
    };
    final success = await context.read<AuthProvider>().updateApplicantProfile(
      data,
      _resumeFile,
    );
    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Profile saved successfully')));
        // Removed Navigator.of(context).pop(); as this screen is often embedded in a tab
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<AuthProvider>().errorMessage ?? 'Failed',
            ),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await context.read<AuthProvider>().fetchApplicantProfile();
    if (profile != null) {
      _phone.text = profile['phone'] ?? '';
      _bio.text = profile['bio'] ?? '';
      _skills.text = profile['skills'] ?? '';
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Applicant Profile'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: Color(0xFFE8EAF6),
                child: Icon(Icons.person, size: 40, color: Color(0xFF1A237E)),
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildReadOnlyField('Username', context.watch<AuthProvider>().userData?['username'] ?? ''),
                    const SizedBox(height: 16),
                    _buildReadOnlyField('Email', context.watch<AuthProvider>().userData?['email'] ?? ''),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _bio,
                      decoration: const InputDecoration(
                        labelText: 'Bio',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                        prefixIcon: Icon(Icons.info_outline),
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _skills,
                      decoration: const InputDecoration(
                        labelText: 'Skills',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.code),
                        hintText: 'e.g. Flutter, Python, SQL',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _pickResume,
                            icon: const Icon(Icons.upload_file),
                            label: const Text('Resume'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[200],
                              foregroundColor: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _resumeFile?.name ?? 'No file selected',
                              style: TextStyle(color: Colors.grey[600]),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        return auth.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                onPressed: _save,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1A237E),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('Save Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[100],
        prefixIcon: Icon(label == 'Email' ? Icons.email : Icons.person_outline),
      ),
    );
  }
}
