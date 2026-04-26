
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
      final dio = Dio();
      final response = await dio.get('https://ipapi.co/json/');
      if (response.statusCode == 200) {
        final data = response.data;
        if (mounted) {
          setState(() {
            _currentLocation = "${data['city']}, ${data['country_name']}";
          });
        }
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
                              'Hello, $fullName 👋',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A237E),
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
                ],
              ),
            ),
          );

    if (!widget.showAppBar) return body;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: widget.showAppBar ? AppBar(
        title: const Text(
          'HireHub', 
          style: TextStyle(
            fontWeight: FontWeight.w900, 
            color: Color(0xFF1A237E),
            fontSize: 22,
          )
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 22),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
          const SizedBox(width: 8),
        ],
      ) : null,
      body: body,
    );
  }

  Widget _buildCompactStats() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1A237E), const Color(0xFF3949AB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A237E).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildCompactStatItem('Total', _stats['total'].toString(), Icons.assignment_outlined),
          _buildVerticalDivider(),
          _buildCompactStatItem('Pending', _stats['pending'].toString(), Icons.timer_outlined),
          _buildVerticalDivider(),
          _buildCompactStatItem('Shortlisted', _stats['shortlisted'].toString(), Icons.verified_outlined),
          _buildVerticalDivider(),
          _buildCompactStatItem('Rejected', _stats['rejected'].toString(), Icons.cancel_outlined),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.white.withValues(alpha: 0.2),
    );
  }

  Widget _buildCompactStatItem(String label, String count, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          count,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 11,
            letterSpacing: 0.5,
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
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Stack(
                children: [
                  _buildActionCard(
                    'Browse Jobs', 
                    Icons.search, 
                    Colors.indigo,
                    () {
                      // Reset notification count when browsing jobs
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
                  ),
                  if (_notificationCount > 0)
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.redAccent.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '$_notificationCount NEW',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                'Edit Profile', 
                Icons.person_outline, 
                Colors.deepPurple,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ApplicantProfileScreen())),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                color: color.withValues(alpha: 0.8),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
