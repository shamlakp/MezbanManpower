
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/job_provider.dart';
import '../utils/url_helper.dart';
import 'company_profile_screen.dart';
import 'create_job_screen.dart';
import 'recruiter_applications_screen.dart';

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
    
    // 60-30-10 Design Tokens (Dynamic)
    final Color neutralBg = isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFB);
    final Color neutralCard = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    const Color primaryDeep = Color(0xFF6366F1); // 30% - Indigo
    final Color primaryLight = isDark ? const Color(0xFF312E81).withOpacity(0.3) : const Color(0xFFEEF2FF);
    const Color accentGold = Color(0xFFF59E0B); // 10% - Gold
    final Color textMain = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final Color textSub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final Color borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    final auth = context.watch<AuthProvider>();
    final user = auth.userData;
    final recruiterName = user?['full_name'] ?? user?['username'] ?? 'Partner';

    return Scaffold(
      backgroundColor: neutralBg,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryDeep))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: primaryDeep,
              child: CustomScrollView(
                slivers: [
                  _buildHeader(recruiterName, isDark, primaryDeep, primaryLight, textMain, textSub),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          _buildMinimalStats(isDark, neutralCard, primaryDeep, accentGold, textMain, textSub),
                          const SizedBox(height: 40),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Manage Companies',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: textMain,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              _buildAddButton(accentGold),
                            ],
                          ),
                          const SizedBox(height: 20),
                          if (_companies.isEmpty)
                            _buildEmptyState(neutralCard, textMain, textSub)
                          else
                            _buildMinimalCompanyList(isDark, neutralCard, neutralBg, primaryDeep, textMain, textSub, borderColor),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader(String name, bool isDark, Color primary, Color primaryLight, Color textMain, Color textSub) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'RECRUITER PORTAL',
                style: TextStyle(
                  color: primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: textMain, letterSpacing: -1),
                children: [
                  const TextSpan(text: 'Welcome back, '),
                  TextSpan(text: name, style: TextStyle(color: primary)),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your centralized hub for talent and company growth.',
              style: TextStyle(fontSize: 15, color: textSub, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMinimalStats(bool isDark, Color cardColor, Color primary, Color accent, Color textMain, Color textSub) {
    return Row(
      children: [
        Expanded(child: _buildStatItem('Companies', _companies.length.toString(), Icons.business, primary, cardColor, textMain, textSub)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatItem('Open Jobs', _totalJobs.toString(), Icons.work_outline, primary, cardColor, textMain, textSub)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatItem('New Apps', _totalApplications.toString(), Icons.people_outline, accent, cardColor, textMain, textSub)),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color, Color cardColor, Color textMain, Color textSub) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.06), blurRadius: 24, offset: const Offset(0, 12)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: textMain),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: textSub, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(Color accent) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (_) => const CompanyProfileScreen()));
        _loadData();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: accent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: accent.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5)),
          ],
        ),
        child: const Row(
          children: [
            Icon(Icons.add, color: Colors.white, size: 18),
            SizedBox(width: 6),
            Text('Register Company', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildMinimalCompanyList(bool isDark, Color cardColor, Color bgColor, Color primary, Color textMain, Color textSub, Color borderColor) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _companies.length,
      separatorBuilder: (context, index) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        return _buildModernCard(_companies[index], isDark, cardColor, bgColor, primary, textMain, textSub, borderColor);
      },
    );
  }

  Widget _buildModernCard(Map<String, dynamic> company, bool isDark, Color cardColor, Color bgColor, Color primary, Color textMain, Color textSub, Color borderColor) {
    final logoUrl = company['logo'];
    final name = company['company_name'] ?? 'Company';

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.03), blurRadius: 30, offset: const Offset(0, 15)),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: (logoUrl != null && logoUrl.isNotEmpty)
                        ? Image.network(
                            UrlHelper.resolveMediaUrl(logoUrl),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(Icons.business, color: textSub),
                          )
                        : Icon(Icons.business, color: textSub),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textMain)),
                      const SizedBox(height: 4),
                      Text('Company profile & recruitment hub', style: TextStyle(fontSize: 13, color: textSub, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                _buildCardMenu(company, textSub),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionBtn(
                    'Post New Job',
                    Icons.add_box_outlined,
                    primary,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => CreateJobScreen(selectedCompanyId: company['id'] as int?))),
                    isPrimary: true,
                    cardColor: cardColor,
                    borderColor: borderColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionBtn(
                    'Applications',
                    Icons.people_outline,
                    textMain,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => RecruiterApplicationsScreen())),
                    isPrimary: false,
                    cardColor: cardColor,
                    borderColor: borderColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(String label, IconData icon, Color color, VoidCallback onTap, {required bool isPrimary, required Color cardColor, required Color borderColor}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isPrimary ? color : cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isPrimary ? color : borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: isPrimary ? Colors.white : color),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: isPrimary ? Colors.white : color, fontSize: 13, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _buildCardMenu(Map<String, dynamic> company, Color textSub) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_horiz, color: textSub),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 18), SizedBox(width: 12), Text('Settings')])),
        const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 18, color: Colors.red), SizedBox(width: 12), Text('Remove', style: TextStyle(color: Colors.red))])),
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
          const Icon(Icons.business_center_outlined, size: 60, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 24),
          Text('Ready to hire?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textMain)),
          const SizedBox(height: 8),
          Text('Register your company to start posting jobs.', textAlign: TextAlign.center, style: TextStyle(color: textSub, fontSize: 14)),
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
        content: Text('Are you sure you want to remove "${company['company_name']}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Delete')),
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
