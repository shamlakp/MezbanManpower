import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';
import '../constants/colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/custom_button.dart';

class ApplicantDocumentsScreen extends StatefulWidget {
  const ApplicantDocumentsScreen({super.key});

  @override
  State<ApplicantDocumentsScreen> createState() => _ApplicantDocumentsScreenState();
}

class _ApplicantDocumentsScreenState extends State<ApplicantDocumentsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<dynamic> _documents = [];

  final List<Map<String, String>> _documentTypes = [
    {'type': 'passport', 'title': 'Passport', 'icon': 'passport'},
    {'type': 'medical', 'title': 'Medical Certificate', 'icon': 'medical_services'},
    {'type': 'visa', 'title': 'Visa Copy', 'icon': 'assignment_ind'},
    {'type': 'ticket', 'title': 'Flight Ticket', 'icon': 'flight_takeoff'},
    {'type': 'education', 'title': 'Educational Certificate', 'icon': 'school'},
    {'type': 'contract', 'title': 'Contract Copy', 'icon': 'description'},
  ];

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.getApplicantDocuments();
      if (response.statusCode == 200) {
        setState(() {
          _documents = response.data;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load documents')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadDocument(String docType) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      
      setState(() => _isLoading = true);
      try {
        final response = await _apiService.uploadApplicantDocument(docType, file);
        if (response.statusCode == 201) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Document uploaded successfully!'), backgroundColor: SuccessColor.c500),
            );
          }
          await _loadDocuments(); // Refresh the list
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload document')),
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'passport': return Icons.badge_outlined;
      case 'medical_services': return Icons.medical_services_outlined;
      case 'assignment_ind': return Icons.assignment_ind_outlined;
      case 'flight_takeoff': return Icons.flight_takeoff_outlined;
      case 'school': return Icons.school_outlined;
      case 'description': return Icons.description_outlined;
      default: return Icons.insert_drive_file_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = BrandColor.c500;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : NeutralColor.c900, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('My Documents', style: TextStyle(color: isDark ? Colors.white : NeutralColor.c900, fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDocuments,
              child: ListView.builder(
                padding: const EdgeInsets.all(24.0),
                itemCount: _documentTypes.length,
                itemBuilder: (context, index) {
                  final docTypeMap = _documentTypes[index];
                  final type = docTypeMap['type']!;
                  
                  // Find if we have uploaded this document
                  final existingDocs = _documents.where((d) => d['document_type'] == type).toList();
                  final hasDocument = existingDocs.isNotEmpty;
                  final docData = hasDocument ? existingDocs.first : null;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: hasDocument ? SuccessColor.c500.withValues(alpha: 0.1) : primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getIcon(docTypeMap['icon']!),
                              color: hasDocument ? SuccessColor.c500 : primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  docTypeMap['title']!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isDark ? Colors.white : NeutralColor.c900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  hasDocument 
                                      ? (docData['is_verified'] ? 'Verified' : 'Pending Verification')
                                      : 'Not Uploaded',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: hasDocument 
                                        ? (docData['is_verified'] ? SuccessColor.c500 : WarningColor.c500)
                                        : NeutralColor.c400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!hasDocument)
                            CustomButton(
                              onPressed: () => _uploadDocument(type),
                              text: 'Upload',
                              buttonBgColor: primary,
                              fontColor: Colors.white,
                              width: 80,
                              height: 36,
                              padding: EdgeInsets.zero,
                              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                            )
                          else
                            IconButton(
                              icon: const Icon(Icons.check_circle, color: SuccessColor.c500),
                              onPressed: () {
                                // Potentially view the document
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Document already uploaded.')),
                                );
                              },
                            )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
