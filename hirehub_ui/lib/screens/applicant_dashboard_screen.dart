import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../constants/colors.dart';
import '../services/api_service.dart';
import 'applicant_applications_screen.dart';
import 'dashboard_screen.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/glass_card.dart';

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
    'total': 0, 'pending': 0, 'shortlisted': 0, 'rejected': 0,
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
        int pending = 0, shortlisted = 0, rejected = 0;
        for (var app in apps) {
          final status = (app['status'] ?? '').toString().toLowerCase();
          if (status == 'pending')                               pending++;
          else if (status == 'shortlisted' || status == 'accepted') shortlisted++;
          else if (status == 'rejected')                         rejected++;
        }
        if (mounted) {
          setState(() {
            _applications = apps;
            _stats = {
              'total': apps.length, 'pending': pending,
              'shortlisted': shortlisted, 'rejected': rejected,
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
    final auth     = context.watch<AuthProvider>();
    final user     = auth.userData;
    final fullName = user?['full_name'] ?? user?['username'] ?? 'Explorer';

    return Scaffold(
      backgroundColor: NeutralColor.c50,
      appBar: widget.showAppBar
          ? AppBar(
              backgroundColor: NeutralColor.c50,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: NeutralColor.c900, size: 20),
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => DashboardScreen()),
                ),
              ),
              title: Text('My Dashboard',
                  style: TextStyle(color: NeutralColor.c900, fontWeight: FontWeight.w800, fontSize: 18)),
              centerTitle: true,
            )
          : null,
      body: _isLoading
          ? const Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                children: [
                  ShimmerLoading(height: 100),
                  SizedBox(height: 28),
                  Row(children: [Expanded(child: ShimmerLoading(height: 80)), SizedBox(width: 12), Expanded(child: ShimmerLoading(height: 80)), SizedBox(width: 12), Expanded(child: ShimmerLoading(height: 80))]),
                  SizedBox(height: 36),
                  ShimmerListLoading(itemCount: 3),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              color: BrandColor.c500,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    _buildWelcomeHeader(fullName),
                    const SizedBox(height: 28),
                    _buildStatsRow(),
                    const SizedBox(height: 36),
                    _buildSectionHeader('Recent Applications', onTap: () =>
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ApplicantApplicationsScreen()))),
                    const SizedBox(height: 14),
                    if (_applications.isEmpty)
                      _buildEmptyState()
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _applications.length > 3 ? 3 : _applications.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => _buildAppCard(_applications[i]),
                      ),
                    const SizedBox(height: 36),
                    _buildDiscoveryBanner(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
    );
  }

  // ── Welcome header ─────────────────────────────────────────
  Widget _buildWelcomeHeader(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(fontSize: 28, color: NeutralColor.c900, letterSpacing: -1),
            children: [
              const TextSpan(text: 'Hello, ', style: TextStyle(fontWeight: FontWeight.w700)),
              TextSpan(text: name, style: TextStyle(color: NeutralColor.c500, fontWeight: FontWeight.w400)),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text('Your career journey starts here.',
            style: TextStyle(fontSize: 15, color: NeutralColor.c600, fontWeight: FontWeight.w500)),
      ],
    );
  }

  // ── Stats row ──────────────────────────────────────────────
  Widget _buildStatsRow() {
    final items = [
      ('Total',      _stats['total'].toString(),       BrandColor.c500,   BrandColor.c50),
      ('Pending',    _stats['pending'].toString(),     WarningColor.c600, WarningColor.c50),
      ('Shortlisted',_stats['shortlisted'].toString(), SuccessColor.c600, SuccessColor.c50),
    ];
    return Row(
      children: items.map((e) => Expanded(
        child: Padding(
          padding: EdgeInsets.only(right: e.$1 == 'Shortlisted' ? 0 : 12),
          child: GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 20),
            opacity: 0.1,
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            child: Column(
              children: [
                Text(e.$2, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: e.$3)),
                const SizedBox(height: 4),
                Text(e.$1, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: NeutralColor.c500)),
              ],
            ),
          ),
        ),
      )).toList(),
    );
  }

  // ── Section header ─────────────────────────────────────────
  Widget _buildSectionHeader(String title, {VoidCallback? onTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: NeutralColor.c900, letterSpacing: -0.3)),
        TextButton(
          onPressed: onTap,
          child: Text('View All', style: TextStyle(color: BrandColor.c500, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  // ── Application card ───────────────────────────────────────
  Widget _buildAppCard(dynamic app) {
    final job     = app['job_details'] ?? {};
    final title   = job['title'] ?? 'Position';
    final company = job['company_name'] ?? 'Organization';
    final status  = (app['status'] ?? 'Pending').toString().toUpperCase();

    Color statusFg, statusBg;
    if (status.contains('SHORTLISTED') || status.contains('ACCEPTED')) {
      statusFg = SuccessColor.c600; statusBg = SuccessColor.c50;
    } else if (status.contains('REJECTED')) {
      statusFg = DangerColor.c500;  statusBg = DangerColor.c50;
    } else {
      statusFg = BrandColor.c500;   statusBg = BrandColor.c50;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: NeutralColor.c100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: NeutralColor.c200),
      ),
      child: Row(
        children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(color: BrandColor.c50, borderRadius: BorderRadius.circular(14)),
            child: Icon(Icons.business_center_outlined, color: BrandColor.c500, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: NeutralColor.c900)),
                Text(company, style: TextStyle(color: NeutralColor.c600, fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(8)),
            child: Text(status, style: TextStyle(color: statusFg, fontSize: 10, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  // ── Discovery banner ───────────────────────────────────────
  Widget _buildDiscoveryBanner() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      color: BrandColor.c50,
      opacity: 0.5,
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: BrandColor.c200.withOpacity(0.5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.explore_rounded, color: BrandColor.c500, size: 32),
          const SizedBox(height: 12),
          Text('Discover New Roles',
              style: TextStyle(color: NeutralColor.c900, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text('Thousands of jobs are waiting for you.',
              style: TextStyle(color: NeutralColor.c600, fontSize: 13)),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: widget.onBrowseJobs,
            style: ElevatedButton.styleFrom(
              backgroundColor: BrandColor.c500,
              foregroundColor: NeutralColor.c50,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Browse Jobs', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  // ── Empty state ────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: NeutralColor.c100,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: NeutralColor.c200),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: NeutralColor.c400),
          const SizedBox(height: 12),
          Text('No applications yet',
              style: TextStyle(fontWeight: FontWeight.w700, color: NeutralColor.c500)),
        ],
      ),
    );
  }
}
