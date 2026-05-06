
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'applicant_profile_screen.dart';
import 'applicant_applications_screen.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';

import '../utils/location_helper.dart';

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
  int _notificationCount = 0; 
  String _currentLocation = 'Detecting...';

  @override
  void initState() {
    super.initState();
    _loadData();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    try {
      final location = await LocationHelper.getExactLocation();
      if (mounted) {
        setState(() {
          _currentLocation = location;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _currentLocation = 'Location Unavailable');
      }
    }
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
          _updateJobNotifications();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading dashboard: $e')),
        );
      }
    }
  }

  Future<void> _updateJobNotifications() async {
    try {
      final api = ApiService();
      final prefs = await SharedPreferences.getInstance();
      final response = await api.getJobs();
      
      if (response.statusCode == 200) {
        final List<dynamic> allJobs = response.data;
        final int currentTotalJobs = allJobs.length;
        final int lastSeenJobCount = prefs.getInt('last_seen_job_count') ?? 0;

        if (mounted) {
          setState(() {
            // Only show count if there are actually new jobs
            _notificationCount = (currentTotalJobs > lastSeenJobCount) 
                ? (currentTotalJobs - lastSeenJobCount) 
                : 0;
          });
        }
        
        // Update the "seen" count if user clicks or navigates to jobs
        // For now, we update it here so notifications disappear after loading the dashboard
        // await prefs.setInt('last_seen_job_count', currentTotalJobs);
      }
    } catch (e) {
      debugPrint('Notification update error: $e');
    }
  }

  Future<void> _logout() async {
    final auth = context.read<AuthProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final navigator = Navigator.of(context);
      try {
        await auth.logout();
      } catch (e) {
        debugPrint('Logout error: $e');
      }
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.userData;
    final fullName = user?['full_name'] ?? user?['username'] ?? 'Applicant';

    final body = _isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0), // Reduced padding for better fit
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, $fullName',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF2D3748),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Find your dream job today',
                              style: TextStyle(
                                color: Colors.grey[600], 
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Logout moved to a subtle trailing button or handled in profile
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildCompactStats(),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Applications',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ApplicantApplicationsScreen()),
                        ),
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_applications.isEmpty)
                    _buildEmptyState()
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _applications.length > 3 ? 3 : _applications.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final app = _applications[index];
                        return _buildApplicationCard(app);
                      },
                    ),
                  const SizedBox(height: 24),
                  _buildQuickActions(),
                  const SizedBox(height: 32),
                  _buildBottomLogoutButton(),
                ],
              ),
            ),
          );

    if (!widget.showAppBar) return body;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: widget.showAppBar ? AppBar(
        title: const Text(
          'MezbanManpower', 
          style: TextStyle(
            fontWeight: FontWeight.w900, 
            color: Color(0xFF1A237E),
            fontSize: 22,
          )
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [
          SizedBox(width: 8),
        ],
      ) : null,
      body: body,
    );
  }

  Widget _buildCompactStats() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildCompactStatItem('Total', _stats['total'].toString(), Icons.assignment_outlined, const Color(0xFF4C51BF)),
          _buildVerticalDivider(),
          _buildCompactStatItem('Pending', _stats['pending'].toString(), Icons.timer_outlined, const Color(0xFFD69E2E)),
          _buildVerticalDivider(),
          _buildCompactStatItem('Shortlisted', _stats['shortlisted'].toString(), Icons.verified_outlined, const Color(0xFF38A169)),
          _buildVerticalDivider(),
          _buildCompactStatItem('Rejected', _stats['rejected'].toString(), Icons.cancel_outlined, const Color(0xFFE53E3E)),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey.withValues(alpha: 0.2),
    );
  }

  Widget _buildCompactStatItem(String label, String count, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          count,
          style: const TextStyle(
            color: Color(0xFF2D3748),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildApplicationCard(Map<String, dynamic> app) {
    final job = app['job_details'] ?? {};
    final company = job['company_name'] ?? 'Company';
    final title = job['title'] ?? 'Job Title';
    final status = app['status'] ?? 'Pending';
    final appliedAt = app['created_at'] != null 
        ? app['created_at'].toString().split('T')[0] 
        : 'Recently';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F2FF),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.business_center_outlined, color: Color(0xFF3949AB), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF2C3E50)),
                ),
                const SizedBox(height: 2),
                Text(
                  company,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildStatusBadge(status),
              const SizedBox(height: 6),
              Text(
                appliedAt,
                style: TextStyle(color: Colors.grey[400], fontSize: 10, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.orange;
    if (status.toLowerCase() == 'shortlisted' || status.toLowerCase() == 'accepted') color = Colors.green;
    if (status.toLowerCase() == 'rejected') color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Column(
          children: [
            Icon(Icons.assignment_late_outlined, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              'No applications yet.',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            TextButton(
              onPressed: () => Navigator.pushReplacement(
                context, 
                MaterialPageRoute(builder: (_) => const DashboardScreen())
              ),
              child: const Text('Find your first job'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3748)),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSmallActionIcon(
              'Jobs', 
              Icons.work_outline, 
              const Color(0xFF4C51BF),
              () {
                SharedPreferences.getInstance().then((prefs) {
                  ApiService().getJobs().then((resp) {
                    if (resp.statusCode == 200) {
                      prefs.setInt('last_seen_job_count', (resp.data as List).length);
                    }
                  });
                });
                
                if (widget.onBrowseJobs != null) {
                  widget.onBrowseJobs!();
                } else {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
                }
              },
              badgeCount: _notificationCount,
            ),
            _buildSmallActionIcon(
              'Profile', 
              Icons.person_outline, 
              const Color(0xFF38A169),
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ApplicantProfileScreen())),
            ),
            _buildSmallActionIcon(
              'Settings', 
              Icons.settings_outlined, 
              const Color(0xFFD69E2E),
              () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings coming soon')));
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallActionIcon(String label, IconData icon, Color color, VoidCallback onTap, {int badgeCount = 0}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                if (badgeCount > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        badgeCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomLogoutButton() {
    return Center(
      child: TextButton.icon(
        onPressed: _logout,
        icon: const Icon(Icons.logout_rounded, color: Colors.grey, size: 20),
        label: const Text(
          'Log Out',
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
