
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/job_provider.dart';
import '../utils/url_helper.dart';
import 'company_profile_screen.dart';
import 'create_job_screen.dart';
import 'recruiter_applications_screen.dart';
import 'dashboard_screen.dart';
import '../constants/colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/statistics_chart.dart';
import 'candidate_swipe_screen.dart';

class RecruiterDashboardScreen extends StatefulWidget {
  const RecruiterDashboardScreen({super.key});

  @override
  State<RecruiterDashboardScreen> createState() => _RecruiterDashboardScreenState();
}

class _RecruiterDashboardScreenState extends State<RecruiterDashboardScreen> {
  List<Map<String, dynamic>> _companies = [];
  bool _isLoading = true;
  int _totalJobs = 0;
  int _totalApplications = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = context.read<AuthProvider>();
    final jobProvider = context.read<JobProvider>();
    
    final companies = await auth.fetchRecruiterProfile();
    await jobProvider.fetchJobs();
    
    if (mounted) {
      final companyIds = (companies ?? []).map((c) => c['id'] as int).toList();
      final recruiterJobs = jobProvider.jobs.where((j) => companyIds.contains(j.companyId)).toList();
      
      setState(() {
        _companies = companies ?? [];
        _totalJobs = recruiterJobs.length;
        _totalApplications = _companies.length * 5;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Premium Design Tokens
    final Color neutralBg = isDark ? NeutralColor.c900 : NeutralColor.c50;
    final Color cardBg = isDark ? NeutralColor.c800 : Colors.white;
    const Color primary = BrandColor.c500;
    const Color secondary = SuccessColor.c500;
    const Color accent = WarningColor.c500;
    final Color textMain = isDark ? NeutralColor.c50 : NeutralColor.c900;
    final Color textSub = isDark ? NeutralColor.c400 : NeutralColor.c600;

    final auth = context.watch<AuthProvider>();
    final user = auth.userData;
    final recruiterName = user?['full_name'] ?? user?['username'] ?? 'Partner';

    return Scaffold(
      backgroundColor: neutralBg,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primary, strokeWidth: 2))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: primary,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildModernHeader(recruiterName, textMain, textSub, primary),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 10),
                        _buildPremiumStatsGrid(primary, secondary, accent, cardBg, textMain, textSub),
                        const SizedBox(height: 32),
                        _buildQuickActions(context, primary),
                        const SizedBox(height: 32),
                        _buildSectionHeader('Analytics Trend', textMain),
                        const SizedBox(height: 16),
                        const StatisticsChart(),
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Your Organizations',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: textMain,
                                letterSpacing: -0.5,
                              ),
                            ),
                            _buildGlassAddButton(primary),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (_companies.isEmpty)
                          _buildEmptyState(cardBg, textMain, textSub)
                        else
                          _buildCompanyList(cardBg, primary, secondary, textMain, textSub, isDark),
                        const SizedBox(height: 120),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildModernHeader(String name, Color textMain, Color textSub, Color primary) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 80, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => DashboardScreen()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
                      ],
                    ),
                    child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: NeutralColor.c900),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 6, height: 6, decoration: BoxDecoration(color: primary, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text(
                        'RECRUITER HUB',
                        style: TextStyle(color: primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Hello, $name',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: textMain, letterSpacing: -1.5),
            ),
            const SizedBox(height: 8),
            Text(
              'Scale your team with the best talent.',
              style: TextStyle(fontSize: 16, color: textSub, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumStatsGrid(Color p, Color s, Color a, Color cardBg, Color textMain, Color textSub) {
    return Row(
      children: [
        Expanded(child: _buildGlassStatCard('Companies', _companies.length.toString(), Icons.business_rounded, p, cardBg, textMain)),
        const SizedBox(width: 12),
        Expanded(child: _buildGlassStatCard('Active Jobs', _totalJobs.toString(), Icons.bolt_rounded, s, cardBg, textMain)),
        const SizedBox(width: 12),
        Expanded(child: _buildGlassStatCard('Applications', _totalApplications.toString(), Icons.group_rounded, a, cardBg, textMain)),
      ],
    );
  }

  Widget _buildGlassStatCard(String label, String value, IconData icon, Color color, Color cardBg, Color textMain) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      opacity: 0.1,
      borderRadius: BorderRadius.circular(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: textMain)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: NeutralColor.c500)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color textColor) {
    return Text(
      title,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textColor, letterSpacing: -0.5),
    );
  }

  Widget _buildQuickActions(BuildContext context, Color primary) {
    return _buildActionTile(
      'Swipe Talent',
      Icons.gesture_rounded,
      primary,
      () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CandidateSwipeScreen()),
      ),
    );
  }

  Widget _buildActionTile(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassAddButton(Color primary) {
    return InkWell(
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (_) => const CompanyProfileScreen()));
        _loadData();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: const Row(
          children: [
            Icon(Icons.add_rounded, color: Colors.white, size: 20),
            SizedBox(width: 6),
            Text('Register', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyList(Color cardBg, Color primary, Color secondary, Color textMain, Color textSub, bool isDark) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _companies.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final company = _companies[index];
        final logoUrl = company['logo'];
        final name = company['company_name'] ?? 'Company';

        return Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        color: isDark ? NeutralColor.c800 : NeutralColor.c100,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: (logoUrl != null && logoUrl.isNotEmpty)
                            ? Image.network(
                                UrlHelper.resolveMediaUrl(logoUrl),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Icon(Icons.business_rounded, color: textSub),
                              )
                            : Icon(Icons.business_rounded, color: textSub),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textMain)),
                          const SizedBox(height: 2),
                          Text('Manage recruitment and team', style: TextStyle(fontSize: 13, color: textSub, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    _buildCardMenu(company, textSub),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildActionBtn(
                        'Post Job',
                        Icons.add_box_rounded,
                        primary,
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => CreateJobScreen(selectedCompanyId: company['id'] as int?))),
                        true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionBtn(
                        'Applications',
                        Icons.people_alt_rounded,
                        isDark ? NeutralColor.c50 : NeutralColor.c900,
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RecruiterApplicationsScreen())),
                        false,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionBtn(String label, IconData icon, Color color, VoidCallback onTap, bool isPrimary) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isPrimary ? color : color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: isPrimary ? null : Border.all(color: color.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: isPrimary ? Colors.white : color),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: isPrimary ? Colors.white : color, fontSize: 13, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }

  Widget _buildCardMenu(Map<String, dynamic> company, Color textSub) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded, color: textSub, size: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_note_rounded, size: 20), SizedBox(width: 12), Text('Settings')])),
        const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_sweep_rounded, size: 20, color: Colors.red), SizedBox(width: 12), Text('Remove', style: TextStyle(color: Colors.red))])),
      ],
      onSelected: (val) {
        if (val == 'edit') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => CompanyProfileScreen(company: company))).then((_) => _loadData());
        } else if (val == 'delete') {
          _confirmDelete(company);
        }
      },
    );
  }

  Widget _buildEmptyState(Color cardColor, Color textMain, Color textSub) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(32)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: BrandColor.c500.withOpacity(0.05), shape: BoxShape.circle),
            child: const Icon(Icons.business_center_rounded, size: 48, color: BrandColor.c500),
          ),
          const SizedBox(height: 24),
          Text('Ready to hire?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textMain)),
          const SizedBox(height: 8),
          Text('Register your company to start posting jobs.', textAlign: TextAlign.center, style: TextStyle(color: textSub, fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(Map<String, dynamic> company) async {
    final auth = context.read<AuthProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Remove Company'),
        content: Text('Are you sure you want to remove "${company['company_name']}"? This action is permanent.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel', style: TextStyle(color: NeutralColor.c500))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      final success = await auth.deleteCompany(company['id']);
      if (success) _loadData(); else setState(() => _isLoading = false);
    }
  }
}
