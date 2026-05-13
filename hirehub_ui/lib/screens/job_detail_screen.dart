
import 'package:flutter/material.dart';
import 'package:hirehub_ui/models/job_post.dart';
import 'package:hirehub_ui/utils/url_helper.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../constants/colors.dart';
import 'apply_job_screen.dart';
import 'login_screen.dart';
import '../widgets/glass_card.dart';
import '../widgets/modern_headline.dart';


class JobDetailScreen extends StatelessWidget {
  final JobPost job;

  const JobDetailScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeutralColor.c50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: NeutralColor.c900),
        title: Text(
          job.companyName,
          style: TextStyle(color: NeutralColor.c900, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: GlassCard(
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                opacity: 0.8,
                color: Colors.white,
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: (job.image != null && job.image!.isNotEmpty)
                            ? Image.network(
                                UrlHelper.resolveMediaUrl(job.image!),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.business, size: 40, color: NeutralColor.c400),
                              )
                            : const Icon(Icons.business, size: 40, color: NeutralColor.c400),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      job.position,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: NeutralColor.c900,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: BrandColor.c50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${job.location} • ${job.workingTime}',
                        style: const TextStyle(fontSize: 12, color: BrandColor.c500, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Job Description'),
                  _buildSectionContent(job.responsibilities.isNotEmpty 
                      ? job.responsibilities 
                      : 'No detailed description provided.'),
                  
                  const SizedBox(height: 24),
                  
                  _buildSectionTitle('Requirements'),
                  _buildSectionContent(job.qualifications.isNotEmpty 
                      ? job.qualifications 
                      : 'No specific requirements listed.'),

                  const SizedBox(height: 24),
                  
                  if (job.benefits.isNotEmpty) ...[
                    _buildSectionTitle('Benefits'),
                    _buildSectionContent(job.benefits),
                    const SizedBox(height: 24),
                  ],

                  const Divider(),
                  const SizedBox(height: 16),

                  // Key Details Grid
                  Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    children: [
                      _buildDetailItem(context, Icons.attach_money, 'Salary', '\$${job.salary}'),
                      _buildDetailItem(context, Icons.schedule, 'Work Schedule', job.workingDays),
                      _buildDetailItem(context, Icons.people, 'Vacancies', '${job.noOfVacancies} Openings'),
                      if (job.annualLeave > 0)
                        _buildDetailItem(context, Icons.flight_takeoff, 'Annual Leave', '${job.annualLeave} Days'),
                      if (job.category.isNotEmpty) 
                        _buildDetailItem(context, Icons.category, 'Category', job.category),
                      if (job.industry.isNotEmpty) 
                        _buildDetailItem(context, Icons.business, 'Industry', job.industry),
                      if (job.accommodation.isNotEmpty) 
                        _buildDetailItem(context, Icons.home_work, 'Accommodation', job.accommodation),
                      if (job.meals.isNotEmpty) 
                        _buildDetailItem(context, Icons.restaurant, 'Meals', job.meals),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Consumer<AuthProvider>(
          builder: (context, auth, child) {
            return ElevatedButton(
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
              style: ElevatedButton.styleFrom(
                backgroundColor: BrandColor.c500,
                foregroundColor: NeutralColor.c50,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('Apply for this Job', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: NeutralColor.c900,
        ),
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Text(
      content,
      style: TextStyle(
        fontSize: 15,
        height: 1.6,
        color: NeutralColor.c800,
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, IconData icon, String label, String value) {
    return Container(
      width: (MediaQuery.of(context).size.width - 72) / 2, // 2 items per row
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: NeutralColor.c200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: BrandColor.c50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: BrandColor.c500),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: NeutralColor.c500, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: NeutralColor.c900,
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
