import 'package:flutter/material.dart';
import 'package:hirehub_ui/models/job_post.dart';
import 'package:hirehub_ui/utils/url_helper.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../providers/auth_provider.dart';
import '../constants/colors.dart';
import 'apply_job_screen.dart';
import 'login_screen.dart';
import '../widgets/custom_button.dart';
import 'dart:math';

class JobDetailScreen extends StatelessWidget {
  final JobPost job;

  const JobDetailScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? Colors.white60 : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Header Background Gradient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 350,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [BrandColor.c900.withValues(alpha: 0.6), const Color(0xFF0F172A)]
                      : [BrandColor.c500.withValues(alpha: 0.15), Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Custom AppBar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 20),
                        onPressed: () => Navigator.pop(context),
                        style: IconButton.styleFrom(
                          backgroundColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                      Text(
                        'Job Details',
                        style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: 48), // Balance for centering
                    ],
                  ),
                ),

                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Section (Glassmorphic)
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(32),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF334155) : Colors.white,
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFF1F5F9)),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.1),
                                            blurRadius: 15,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(24),
                                        child: (job.image != null && job.image!.isNotEmpty)
                                            ? Image.network(
                                                UrlHelper.resolveMediaUrl(job.image!),
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) =>
                                                    Icon(Icons.business_rounded, size: 40, color: subtitleColor),
                                              )
                                            : Icon(Icons.business_rounded, size: 40, color: subtitleColor),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      job.position,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        color: textColor,
                                        letterSpacing: -0.5,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      job.companyName,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: BrandColor.c500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    Wrap(
                                      alignment: WrapAlignment.center,
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        _buildChip(Icons.location_on_rounded, job.location, isDark),
                                        _buildChip(Icons.access_time_rounded, job.workingTime, isDark),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Content Section
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('Job Description', textColor),
                              _buildSectionContent(job.responsibilities.isNotEmpty 
                                  ? job.responsibilities 
                                  : 'No detailed description provided.', subtitleColor),
                              
                              const SizedBox(height: 24),
                              
                              _buildSectionTitle('Requirements', textColor),
                              _buildSectionContent(job.qualifications.isNotEmpty 
                                  ? job.qualifications 
                                  : 'No specific requirements listed.', subtitleColor),

                              const SizedBox(height: 24),
                              
                              if (job.benefits.isNotEmpty) ...[
                                _buildSectionTitle('Benefits', textColor),
                                _buildSectionContent(job.benefits, subtitleColor),
                                const SizedBox(height: 24),
                              ],

                              const Divider(height: 32),
                              _buildSectionTitle('Key Details', textColor),
                              const SizedBox(height: 16),

                              // Key Details Grid
                              Wrap(
                                spacing: 16,
                                runSpacing: 16,
                                children: [
                                  _buildDetailItem(context, Icons.payments_rounded, 'Salary', '\$${job.salary}', isDark),
                                  _buildDetailItem(context, Icons.calendar_month_rounded, 'Schedule', job.workingDays, isDark),
                                  _buildDetailItem(context, Icons.people_alt_rounded, 'Vacancies', '${job.noOfVacancies} Openings', isDark),
                                  if (job.annualLeave > 0)
                                    _buildDetailItem(context, Icons.flight_takeoff_rounded, 'Annual Leave', '${job.annualLeave} Days', isDark),
                                  if (job.department.isNotEmpty)
                                    _buildDetailItem(context, Icons.domain_rounded, 'Department', job.department, isDark),
                                  if (job.category.isNotEmpty) 
                                    _buildDetailItem(context, Icons.category_rounded, 'Category', job.category, isDark),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Consumer<AuthProvider>(
          builder: (context, auth, child) {
            return CustomButton(
              onPressed: () {
                if (!auth.isAuthenticated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please login to apply for this job')),
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ApplyJobScreen(job: job)),
                );
              },
              buttonBgColor: BrandColor.c500,
              fontColor: Colors.white,
              elevation: 5,
              height: 56,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              text: 'Apply for this Job',
              textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white),
            );
          },
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withValues(alpha: 0.2) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: isDark ? Colors.white70 : const Color(0xFF64748B)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white70 : const Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  Widget _buildSectionContent(String content, Color color) {
    return Text(
      content,
      style: TextStyle(
        fontSize: 15,
        height: 1.6,
        color: color,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, IconData icon, String label, String value, bool isDark) {
    double itemWidth = (MediaQuery.of(context).size.width - 64) / 2;
    itemWidth = max(150.0, itemWidth);

    return Container(
      width: itemWidth,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFE2E8F0)),
            ),
            child: Icon(icon, size: 20, color: BrandColor.c500),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : const Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF334155),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

