import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/platform_provider.dart';
import '../widgets/job_grid_card.dart';
import '../widgets/filter_sidebar.dart';
import '../widgets/hero_search_bar.dart';
import '../utils/url_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'login_screen.dart';
import 'applicant_profile_screen.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'job_detail_screen.dart';
import 'recruiter_profile_screen.dart';
import 'recruiter_applications_screen.dart';

import 'applicant_applications_screen.dart';
import 'applicant_dashboard_screen.dart';
import 'admin_profile_screen.dart';
import 'create_job_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _currentLocation = 'Detecting...';
  int _notificationCount = 0;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final jobProvider = context.read<JobProvider>();
      final platformProvider = context.read<PlatformProvider>();
      await jobProvider.fetchJobs();
      await platformProvider.fetchSettings();
      await _fetchLocation();
      await _updateJobNotifications();
    });
  }

  Future<void> _fetchLocation() async {
    try {
      final dio = Dio();
      final response = await dio.get('https://ipapi.co/json/');
      if (response.statusCode == 200) {
        final data = response.data;
        setState(() {
          _currentLocation = "${data['city']}, ${data['country_name']}";
        });
      }
    } catch (e) {
      setState(() { _currentLocation = 'Location Unavailable'; });
    }
  }

  Future<void> _updateJobNotifications() async {
    try {
      final jobProvider = context.read<JobProvider>();
      final prefs = await SharedPreferences.getInstance();
      final int currentTotalJobs = jobProvider.jobs.length;
      final int lastSeen = prefs.getInt('last_seen_job_count') ?? 0;
      setState(() {
        _notificationCount = (currentTotalJobs > lastSeen) ? (currentTotalJobs - lastSeen) : 0;
      });
    } catch (e) {
      // ignore errors
    }
  }

  Future<void> _clearJobNotifications() async {
    try {
      final jobProvider = context.read<JobProvider>();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('last_seen_job_count', jobProvider.jobs.length);
      setState(() {
        _notificationCount = 0;
      });
    } catch (e) {
      // ignore
    }
  }


  Future<void> _logout() async {
    final authProvider = context.read<AuthProvider>();
    final navigator = Navigator.of(context);

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

    if (confirmed ?? false) {
      try {
        await authProvider.logout();
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
    final username = auth.userData?['username'] ?? 'User';
    debugPrint('DashboardScreen: userData: ${auth.userData}');
    final rawUserType = (auth.userData?['user_type'] ?? auth.userData?['role'] ?? 'applicant').toString().toLowerCase();
    
    // Normalize userType
    final String userType;
    if (rawUserType.contains('admin')) {
      userType = 'admin';
    } else if (rawUserType.contains('recruiter')) {
      userType = 'recruiter';
    } else {
      userType = 'applicant';
    }
    
    final isDesktop = MediaQuery.of(context).size.width > 900;
    final bool isApplicant = userType == 'applicant';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            const Icon(Icons.location_on_rounded, color: Color(0xFF673AB7), size: 20),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                _currentLocation,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Badge(
              label: Text('$_notificationCount', style: const TextStyle(color: Colors.white, fontSize: 10)),
              child: const Icon(Icons.notifications_outlined, color: Color(0xFF673AB7)),
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: isDesktop ? null : _buildDrawer(context, username, userType),
      endDrawer: isDesktop ? null : const Drawer(
        child: SafeArea(child: FilterSidebar()),
      ),
      body: _buildBody(userType, isDesktop, isApplicant),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFF673AB7),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: isApplicant 
          ? const [
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
              BottomNavigationBarItem(icon: Icon(Icons.search), activeIcon: Icon(Icons.search), label: 'Jobs'),
              BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), activeIcon: Icon(Icons.assignment), label: 'Applications'),
            ]
          : const [
              BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: 'Applications'),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
            ],
      ),
      floatingActionButton: userType == 'recruiter' && _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateJobScreen())),
              backgroundColor: const Color(0xFF673AB7),
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  String _getTabTitle(int index, String userType) {
    if (userType == 'applicant') {
      switch (index) {
        case 0: return 'My Profile';
        case 1: return 'Explore Jobs';
        case 2: return 'My Applications';
        default: return '';
      }
    }
    switch (index) {
      case 0: return 'HireHub';
      case 1: return 'Applications';
      case 2: return 'Profile';
      default: return '';
    }
  }

  Widget _buildBody(String userType, bool isDesktop, bool isApplicant) {
    final auth = context.watch<AuthProvider>();
    final bool isPublicTab = isApplicant ? _currentIndex == 1 : _currentIndex == 0;
    
    // Treat null userData as unauthenticated for private tabs to prevent crashes/weird states
    if ((!auth.isAuthenticated || auth.userData == null) && !isPublicTab) {
      return _buildAuthPlaceholder();
    }

    if (isApplicant) {
      switch (_currentIndex) {
        case 0: return ApplicantDashboardScreen(
          showAppBar: false, 
          onBrowseJobs: () => setState(() {
            _currentIndex = 1;
            _clearJobNotifications();
          }),
        );
        case 1: return _buildHomeBody(context, isDesktop, userType);
        case 2: return const ApplicantApplicationsScreen();
        default: return const SizedBox.shrink();
      }
    }

    // Default 3-tab logic for others
    if (_currentIndex == 0) return _buildHomeBody(context, isDesktop, userType);
    return _buildOtherScreen(_currentIndex, userType);
  }

  Widget _buildHomeBody(BuildContext context, bool isDesktop, String userType) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Search Bar
          const HeroSearchBar(),
          
          const SizedBox(height: 16),
          
          // 2. Categories Section (Round symbols)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Categories',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120, // Slightly taller for better aspect
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: 6,
              itemBuilder: (context, index) {
                final categories = ['IT', 'Design', 'Sales', 'Finance', 'HR', 'Support'];
                final imagePaths = [
                  'https://images.unsplash.com/photo-1518770660439-4636190af475?w=200&h=200&fit=crop', // IT
                  'https://images.unsplash.com/photo-1558655146-d09347e92766?w=200&h=200&fit=crop', // Design
                  'https://images.unsplash.com/photo-1552581234-26160f608093?w=200&h=200&fit=crop', // Sales
                  'https://images.unsplash.com/photo-1526304640581-d334cdbbf45e?w=200&h=200&fit=crop', // Finance
                  'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?w=200&h=200&fit=crop', // HR
                  'https://images.unsplash.com/photo-1486312338219-ce68d2c6f44d?w=200&h=200&fit=crop', // Support
                ];
                return GestureDetector(
                  onTap: () {
                    context.read<JobProvider>().searchJobs(categories: [categories[index]]);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            image: DecorationImage(
                              image: NetworkImage(imagePaths[index]),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                Colors.black.withValues(alpha: 0.1),
                                BlendMode.darken,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          categories[index],
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          const SizedBox(height: 16),
          
          const SizedBox(height: 16),
          
          // 3. Compact Hero Section with Contact Buttons
          _buildCompactHero(context),

          const SizedBox(height: 24),

          // 4. Jobs Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildSortAndFoundRow(),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isDesktop) const FilterSidebar(),
                  if (isDesktop) const SizedBox(width: 32),
                  Expanded(
                    child: _buildJobGrid(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherScreen(int index, String userType) {
    if (!context.watch<AuthProvider>().isAuthenticated) {
      return _buildAuthPlaceholder();
    }

    if (index == 1) {
      // For now, these still return Scaffolds which might cause double AppBars.
      // In a real app we'd refactor them to be just the body.
      return userType == 'applicant' ? const ApplicantApplicationsScreen() : const RecruiterApplicationsScreen();
    } else {
      if (userType == 'admin') return const AdminProfileScreen();
      return userType == 'applicant' ? const ApplicantProfileScreen() : const RecruiterProfileScreen();
    }
  }

  Widget _buildAuthPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Please sign in to view this page'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF673AB7),
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }

  Widget _buildSortAndFoundRow() {
    return Consumer<JobProvider>(
      builder: (context, provider, child) {
        final isMobile = MediaQuery.of(context).size.width <= 900;
        return Row(
          children: [
            if (isMobile)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  icon: const Icon(Icons.filter_list, color: Color(0xFF673AB7)),
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                  tooltip: 'Filter Jobs',
                ),
              ),
            Expanded(
              child: Text(
                '${provider.jobs.length} Jobs found',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (!isMobile) const SizedBox(width: 16),
            if (!isMobile)
              TextButton(
                onPressed: () => provider.clearSearch(),
                child: const Text('Clear All'),
              ),
            if (!isMobile) const Spacer(),
            const Text('Sort by '),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: provider.currentSort,
                  isDense: true,
                  style: const TextStyle(color: Colors.black87, fontSize: 13),
                  items: ['Relevance', 'Newest First', 'Salary: High to Low']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      provider.setSort(val);
                    }
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildJobGrid() {
    return Consumer<JobProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(40.0),
            child: CircularProgressIndicator(),
          ));
        }

        if (provider.errorMessage != null) {
          return Center(
            child: Column(
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                Text(provider.errorMessage!),
                ElevatedButton(
                  onPressed: () => provider.fetchJobs(),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        if (provider.jobs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: Text('No jobs found'),
            ),
          );
        }

        final size = MediaQuery.of(context).size;
        final bool isDesktop = size.width > 900;
        
        // Grid Configuration
        // Mobile: 2 columns (Compact tiles)
        // Mid-sized: 2 columns (Larger cards)
        // XL-Desktop: 3 columns (Information dense)
        int crossAxisCount = 2; // Default to 2 for mobile
        if (size.width > 1200) {
          crossAxisCount = 3;
        } else if (size.width < 500) {
          // Standard phone
          crossAxisCount = 2;
        }

        // Child Aspect Ratio logic to avoid overflows
        // In 2-col mode, cards are narrow and need to be taller (Portrait)
        // Ratio = Width / Height. If height > width, ratio < 1.0
        double childAspectRatio = 0.8; // Standard portrait card ratio
        if (isDesktop) {
          childAspectRatio = crossAxisCount == 3 ? 1.4 : 1.6;
        } else {
          // Mobile fine-tuning
          // On mobile, if we have 2 columns, width per card is ~180-200px
          // To fit content, height should be ~280-320px
          childAspectRatio = (size.width / crossAxisCount) / 320; 
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16, // tighter for 2-col
            mainAxisSpacing: 16,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: provider.jobs.length,
          itemBuilder: (context, index) {
          return JobGridCard(
              job: provider.jobs[index],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => JobDetailScreen(job: provider.jobs[index]), // Fix: Pass job object
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context, String username, String userType) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(username),
            accountEmail: Text(userType.toUpperCase()),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Color(0xFF673AB7)),
            ),
            decoration: const BoxDecoration(color: Color(0xFF673AB7)),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_outlined),
            title: const Text('Dashboard'),
            onTap: () => Navigator.pop(context),
          ),
          if (userType == 'applicant')
            ListTile(
              leading: const Icon(Icons.history_outlined),
              title: const Text('My Applications'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ApplicantApplicationsScreen()),
                );
              },
            ),
          if (userType == 'recruiter')
            ListTile(
              leading: const Icon(Icons.assignment_outlined),
              title: const Text('Manage Applications'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RecruiterApplicationsScreen()),
                );
              },
            ),
          if (userType == 'admin') ...[
            const Divider(),
            const Padding(
              padding: EdgeInsets.only(left: 16.0, top: 8.0, bottom: 4.0),
              child: Text(
                'ADMIN PANEL',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings_outlined, color: Colors.blueAccent),
              title: const Text('Admin Dashboard'),
              subtitle: const Text('Manage jobs & recruiters'),
              onTap: () {
                Navigator.pop(context);
                UrlHelper.launchBackendUrl('/adminpanel/dashboard/');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_suggest_outlined, color: Colors.orangeAccent),
              title: const Text('Django Admin'),
              subtitle: const Text('Core database management'),
              onTap: () {
                Navigator.pop(context);
                UrlHelper.launchBackendUrl('/admin/');
              },
            ),
          ],
          const Divider(),
          if (context.watch<AuthProvider>().isAuthenticated)
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                _logout();
              },
            )
          else
            ListTile(
              leading: const Icon(Icons.login, color: Color(0xFF673AB7)),
              title: const Text('Sign In'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCompactHero(BuildContext context) {
    return Consumer<PlatformProvider>(
      builder: (context, provider, child) {
        final settings = provider.settings;
        if (settings == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            height: 140, // Compact height
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: const DecorationImage(
                image: AssetImage('assets/images/slider_1.jpg'),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Looking for a job?',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Contact us for immediate help',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          _buildCircleIcon(
                            icon: Icons.phone,
                            color: Colors.white,
                            bgColor: const Color(0xFF673AB7),
                            onTap: () => launchUrl(Uri.parse('tel:${settings.phoneNumber}')),
                          ),
                          const SizedBox(width: 12),
                          _buildCircleIcon(
                            icon: Icons.chat,
                            color: Colors.white,
                            bgColor: const Color(0xFF25D366),
                            onTap: () {
                              final whatsappUrl = 'https://wa.me/${settings.whatsappNumber.replaceAll(RegExp(r'[^0-9]'), '')}';
                              launchUrl(Uri.parse(whatsappUrl), mode: LaunchMode.externalApplication);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCircleIcon({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
