
import 'package:flutter/material.dart';
import '../models/job_application.dart';
import '../utils/url_helper.dart';

class ApplicantDetailScreen extends StatelessWidget {
  final JobApplication application;

  const ApplicantDetailScreen({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textMain = isDark ? Colors.white : const Color(0xFF0F172A);
    final Color textSub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final Color surfaceColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
    const Color primary = Color(0xFF0EA5E9);

    final details = application.applicantDetails ?? {};
    final String email = details['email'] ?? 'Not provided';
    final String phone = details['phone'] ?? 'Not provided';
    final String skills = details['skills'] ?? 'No skills listed';
    final String bio = details['bio'] ?? 'No bio provided';
    final String resumeUrl = details['resume'] ?? '';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textMain, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Applicant Profile',
          style: TextStyle(color: textMain, fontWeight: FontWeight.w800, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: primary.withOpacity(0.1),
                    backgroundImage: details['profile_image'] != null
                        ? NetworkImage(UrlHelper.resolveMediaUrl(details['profile_image']))
                        : null,
                    child: details['profile_image'] == null
                        ? Text(
                            application.applicantName[0].toUpperCase(),
                            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: primary),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    application.applicantName,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: textMain, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    application.jobPosition,
                    style: TextStyle(fontSize: 16, color: textSub, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  _buildStatusBadge(application.status),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Bio Section
            _buildSectionTitle('About Me', Icons.person_outline_rounded),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                bio,
                style: TextStyle(fontSize: 15, color: textMain.withOpacity(0.8), height: 1.6),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Contact Information
            _buildSectionTitle('Contact Info', Icons.alternate_email_rounded),
            const SizedBox(height: 12),
            _buildInfoCard([
              _buildInfoRow(Icons.email_outlined, 'Email', email, primary),
              const Divider(height: 24),
              _buildInfoRow(Icons.phone_outlined, 'Phone', phone, primary),
            ], surfaceColor),
            
            const SizedBox(height: 32),
            
            // Skills Section
            _buildSectionTitle('Skills & Expertise', Icons.auto_awesome_outlined),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills.split(',').map((s) => _buildSkillChip(s.trim(), primary)).toList(),
            ),
            
            const SizedBox(height: 32),
            
            // Resume Section
            if (resumeUrl.isNotEmpty) ...[
              _buildSectionTitle('Resume', Icons.description_outlined),
              const SizedBox(height: 12),
              InkWell(
                onTap: () {
                   final url = UrlHelper.resolveMediaUrl(resumeUrl);
                   // You can use url_launcher here if installed, 
                   // but for now we'll just print or use a placeholder logic
                   debugPrint('Opening resume: $url');
                },
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: primary.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.picture_as_pdf_rounded, color: Colors.redAccent, size: 32),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Professional Resume', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: textMain)),
                            Text('PDF Document', style: TextStyle(color: textSub, fontSize: 12)),
                          ],
                        ),
                      ),
                      const Icon(Icons.download_rounded, color: primary),
                    ],
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF0EA5E9)),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF64748B), letterSpacing: 1),
        ),
      ],
    );
  }

  Widget _buildInfoCard(List<Widget> children, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color primary) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: primary),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w600)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          ],
        ),
      ],
    );
  }

  Widget _buildSkillChip(String skill, Color primary) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        skill,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'shortlisted': color = const Color(0xFF10B981); break;
      case 'rejected': color = const Color(0xFFEF4444); break;
      default: color = const Color(0xFF0EA5E9);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900),
      ),
    );
  }
}
