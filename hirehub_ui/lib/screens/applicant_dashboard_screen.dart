
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import 'applicant_applications_screen.dart';

class ApplicantDashboardScreen extends StatefulWidget {
  final bool showAppBar;
  final VoidCallback? onBrowseJobs;
  const ApplicantDashboardScreen({super.key, this.showAppBar = true, this.onBrowseJobs});

  @override
  State<ApplicantDashboardScreen> createState() => _ApplicantDashboardScreenState();
}

class _ApplicantDashboardScreenState extends State<ApplicantDashboardScreen> {
  bool _isLoading = true;
  List<dynamic> _applications = [];
  Map<String, dynamic> _stats = {
    'total': 0,
    'pending': 0,
    'shortlisted': 0,
    'rejected': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final api = ApiService();
      final response = await api.getApplications();
      if (response.statusCode == 200) {
        final List<dynamic> apps = response.data;
        int pending = 0;
        int shortlisted = 0;
        int rejected = 0;

        for (var app in apps) {
          final status = (app['status'] ?? '').toString().toLowerCase();
          if (status == 'pending') {
            pending++;
          } else if (status == 'shortlisted' || status == 'accepted') {
            shortlisted++;
          } else if (status == 'rejected') {
            rejected++;
          }
        }

        if (mounted) {
          setState(() {
            _applications = apps;
            _stats = {
              'total': apps.length,
              'pending': pending,
              'shortlisted': shortlisted,
              'rejected': rejected,
            };
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.userData;
    final fullName = user?['full_name'] ?? user?['username'] ?? 'Explorer';

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFB),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: const Color(0xFF6366F1),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildWelcomeHeader(fullName),
                    const SizedBox(height: 32),
                    _buildPremiumStats(),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Applications',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.5),
                        ),
                        TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ApplicantApplicationsScreen())),
                          child: const Text('View All', style: TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_applications.isEmpty)
                      _buildEmptyState()
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _applications.length > 3 ? 3 : _applications.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          return _buildModernAppCard(_applications[index]);
                        },
                      ),
                    const SizedBox(height: 40),
                    _buildDiscoverySection(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildWelcomeHeader(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -1),
            children: [
              const TextSpan(text: 'Hello, '),
              TextSpan(text: name, style: const TextStyle(color: Color(0xFF6366F1))),
            ],
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Your career journey starts here.',
          style: TextStyle(fontSize: 15, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildPremiumStats() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 30, offset: const Offset(0, 15)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatIndicator('Total', _stats['total'].toString(), const Color(0xFF6366F1)),
          _buildStatIndicator('Pending', _stats['pending'].toString(), const Color(0xFFF59E0B)),
          _buildStatIndicator('Shortlisted', _stats['shortlisted'].toString(), const Color(0xFF10B981)),
        ],
      ),
    );
  }

  Widget _buildStatIndicator(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
        ),
      ],
    );
  }

  Widget _buildModernAppCard(dynamic app) {
    final job = app['job_details'] ?? {};
    final title = job['title'] ?? 'Position';
    final company = job['company_name'] ?? 'Organization';
    final status = (app['status'] ?? 'Pending').toString().toUpperCase();

    Color statusColor;
    if (status.contains('SHORTLISTED') || status.contains('ACCEPTED')) {
      statusColor = const Color(0xFF10B981);
    } else if (status.contains('REJECTED')) {
      statusColor = const Color(0xFFEF4444);
    } else {
      statusColor = const Color(0xFF6366F1);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.business_center_outlined, color: Color(0xFF6366F1), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1E293B))),
                Text(company, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoverySection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Discover New Roles', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('Thousands of jobs are waiting for you.', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: widget.onBrowseJobs,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF6366F1),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Browse Jobs', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), border: Border.all(color: const Color(0xFFF1F5F9))),
      child: const Column(
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: Color(0xFFE2E8F0)),
          SizedBox(height: 12),
          Text('No applications yet', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }
}
