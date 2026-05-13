import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../providers/job_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/platform_provider.dart';
import '../widgets/job_grid_card.dart';
import '../widgets/filter_sidebar.dart';
import '../widgets/hero_search_bar.dart';
import '../widgets/floating_bottom_nav.dart';
import '../utils/url_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'login_screen.dart';
import 'applicant_profile_screen.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'job_detail_screen.dart';
import 'recruiter_profile_screen.dart';
import 'recruiter_applications_screen.dart';
import 'recruiter_dashboard_screen.dart';

import 'applicant_applications_screen.dart';
import 'applicant_dashboard_screen.dart';
import 'admin_profile_screen.dart';
import 'create_job_screen.dart';

import '../utils/location_helper.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:icons_plus/icons_plus.dart';

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
      final location = await LocationHelper.getExactLocation();
      if (mounted) {
        setState(() {
          _currentLocation = location;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() { _currentLocation = 'Location Unavailable'; });
      }
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
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
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
      extendBody: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        toolbarHeight: 75,
        leading: Builder(
          builder: (context) => Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: auth.isAuthenticated 
              ? PopupMenuButton<String>(
                  offset: const Offset(0, 50),
                    onSelected: (value) {
                      if (value == 'dashboard') {
                        if (userType == 'admin') {
                          // Admin stays on feed or we show a message
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('You are on the main dashboard. Use sidebar for admin tools.')),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => userType == 'applicant' ? const ApplicantDashboardScreen() : const RecruiterDashboardScreen()),
                          );
                        }
                      } else if (value == 'profile') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => userType == 'applicant' 
                              ? const ApplicantProfileScreen() 
                              : userType == 'admin' 
                                ? const AdminProfileScreen() 
                                : const RecruiterProfileScreen()
                          ),
                        );
                      } else if (value == 'logout') {
                        _logout();
                      }
                    },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'dashboard',
                      child: Row(
                        children: [
                          Icon(Icons.dashboard_rounded, color: BrandColor.c500, size: 20),
                          const SizedBox(width: 12),
                          const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'profile',
                      child: Row(
                        children: [
                          Icon(Icons.person_outline_rounded, color: NeutralColor.c600, size: 20),
                          const SizedBox(width: 12),
                          Text('My Profile'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout_rounded, color: DangerColor.c500, size: 20),
                          const SizedBox(width: 12),
                          const Text('Logout', style: TextStyle(color: DangerColor.c500)),
                        ],
                      ),
                    ),
                  ],
                  child: CircleAvatar(
                    backgroundColor: BrandColor.c50,
                    child: Text(
                      username[0].toUpperCase(),
                      style: const TextStyle(color: BrandColor.c500, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              : GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen())),
                  child: const CircleAvatar(
                    backgroundColor: BrandColor.c50,
                    child: Icon(Icons.person_outline_rounded, color: BrandColor.c500),
                  ),
                ),
          ),
        ),
        centerTitle: true,
        title: GestureDetector(
          onTap: _fetchLocation,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: NeutralColor.c100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on_rounded, color: BrandColor.c500, size: 16),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    _currentLocation,
                    style: const TextStyle(
                      fontSize: 12, 
                      fontWeight: FontWeight.w700, 
                      color: NeutralColor.c900,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded, color: NeutralColor.c600, size: 14),
              ],
            ),
          ),
        ),
        actions: [
          Consumer<PlatformProvider>(
            builder: (context, platform, child) {
              return IconButton(
                icon: Icon(
                  platform.themeMode == ThemeMode.light 
                    ? Icons.dark_mode_outlined 
                    : Icons.light_mode_outlined,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
                onPressed: () => platform.toggleTheme(),
              );
            },
          ),
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_none_rounded, color: Theme.of(context).colorScheme.onBackground, size: 28),
                onPressed: () {},
              ),
              if (_notificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: DangerColor.c500, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '$_notificationCount',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildDrawer(context, username, userType),
      endDrawer: isDesktop ? null : const Drawer(
        child: SafeArea(child: FilterSidebar()),
      ),
      body: _buildBody(userType, isDesktop, isApplicant),
      bottomNavigationBar: FloatingBottomNav(
        currentIndex: _currentIndex,
        isApplicant: isApplicant,
        onTap: (index) {
          setState(() => _currentIndex = index);
          // Clear notifications when visiting Explore (Job Feed)
          final bool isExploreTab = isApplicant ? index == 0 : index == 1;
          if (isExploreTab) {
            _clearJobNotifications();
          }
        },
      ),
      floatingActionButton: userType == 'recruiter' && _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateJobScreen())),
              backgroundColor: BrandColor.c500,
              foregroundColor: NeutralColor.c50,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  String _getTabTitle(int index, String userType) {
    if (userType == 'applicant') {
      switch (index) {
        case 0: return 'Explore Jobs';
        case 1: return 'My Applications';
        default: return '';
      }
    }
    switch (index) {
      case 0: return 'Dashboard';
      case 1: return 'Applications';
      default: return '';
    }
  }

  Widget _buildBody(String userType, bool isDesktop, bool isApplicant) {
    final auth = context.watch<AuthProvider>();
    final bool isPublicTab = isApplicant ? _currentIndex == 0 : _currentIndex == 0;
    
    if ((!auth.isAuthenticated || auth.userData == null) && !isPublicTab) {
      return _buildAuthPlaceholder();
    }

    if (isApplicant) {
      switch (_currentIndex) {
        case 0: return _buildHomeBody(context, isDesktop, userType);
        case 1: return const ApplicantDashboardScreen(showAppBar: false); // Hide appbar when in bottom nav
        case 2: return const ApplicantApplicationsScreen();
        default: return const SizedBox.shrink();
      }
    }

    switch (_currentIndex) {
      case 0: 
        if (userType == 'recruiter') return const RecruiterDashboardScreen();
        return _buildHomeBody(context, isDesktop, userType);
      case 1:
        return _buildHomeBody(context, isDesktop, userType);
      case 2:
        if (userType == 'recruiter') return const RecruiterApplicationsScreen();
        return const ApplicantApplicationsScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDrawer(BuildContext context, String username, String userType) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = BrandColor.c500;
    
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primary, primary.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  child: Text(
                    username[0].toUpperCase(),
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primary),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  username,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                ),
                Text(
                  userType.toUpperCase(),
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                _buildDrawerItem(
                  icon: Icons.dashboard_rounded,
                  title: 'My Dashboard',
                  onTap: () {
                    Navigator.pop(context);
                    if (userType == 'admin') {
                       // Already on main dashboard
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => userType == 'applicant' ? const ApplicantDashboardScreen() : const RecruiterDashboardScreen()),
                      );
                    }
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.person_outline_rounded,
                  title: 'My Profile',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => userType == 'applicant' 
                          ? const ApplicantProfileScreen() 
                          : userType == 'admin' 
                            ? const AdminProfileScreen() 
                            : const RecruiterProfileScreen()
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.description_outlined,
                  title: 'My Applications',
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _currentIndex = 1);
                  },
                ),
                if (userType == 'admin') ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Text('ADMINISTRATION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: NeutralColor.c400, letterSpacing: 1.5)),
                  ),
                  _buildDrawerItem(
                    icon: Icons.admin_panel_settings_outlined,
                    title: 'Admin Dashboard',
                    onTap: () => UrlHelper.launchBackendUrl('/adminpanel/dashboard/'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.settings_suggest_outlined,
                    title: 'Django Admin Panel',
                    onTap: () => UrlHelper.launchBackendUrl('/admin/'),
                  ),
                ],
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Divider(height: 32),
                ),
                _buildDrawerItem(
                  icon: Icons.logout_rounded,
                  title: 'Logout',
                  iconColor: Colors.redAccent,
                  onTap: () {
                    Navigator.pop(context);
                    _logout();
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'v2.4.0 High-Tech Edition',
              style: TextStyle(color: Colors.grey.withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({required IconData icon, required String title, required VoidCallback onTap, Color? iconColor}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Icon(icon, color: iconColor ?? NeutralColor.c700, size: 24),
      title: Text(
        title,
        style: TextStyle(
          color: iconColor ?? NeutralColor.c900,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
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
              itemCount: 10,
              itemBuilder: (context, index) {
                final categories = ['IT', 'Design', 'Sales', 'Finance', 'HR', 'Support', 'Marketing', 'Engineering', 'Healthcare', 'Education'];
                final imagePaths = [
                  'https://images.unsplash.com/photo-1518770660439-4636190af475?w=200&h=200&fit=crop', // IT
                  'https://images.unsplash.com/photo-1558655146-d09347e92766?w=200&h=200&fit=crop', // Design
                  'https://images.unsplash.com/photo-1552581234-26160f608093?w=200&h=200&fit=crop', // Sales
                  'https://images.unsplash.com/photo-1526304640581-d334cdbbf45e?w=200&h=200&fit=crop', // Finance
                  'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?w=200&h=200&fit=crop', // HR
                  'https://images.unsplash.com/photo-1486312338219-ce68d2c6f44d?w=200&h=200&fit=crop', // Support
                  'https://images.unsplash.com/photo-1533750516457-a7f992034fec?w=200&h=200&fit=crop', // Marketing
                  'https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?w=200&h=200&fit=crop', // Engineering
                  'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?w=200&h=200&fit=crop', // Healthcare
                  'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=200&h=200&fit=crop', // Education
                ];
                return GestureDetector(
                  onTap: () {
                    final provider = context.read<JobProvider>();
                    provider.clearSearch(); // Clear other filters first
                    provider.searchJobs(categories: [categories[index]]);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Showing ${categories[index]} jobs'),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: BrandColor.c500,
                      ),
                    );
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
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            image: DecorationImage(
                              image: NetworkImage(imagePaths[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          categories[index],
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: NeutralColor.c900,
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
              backgroundColor: BrandColor.c500,
              foregroundColor: NeutralColor.c50,
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
                child: Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Bootstrap.filter, color: BrandColor.c500),
                    onPressed: () => Scaffold.of(context).openEndDrawer(),
                    tooltip: 'Filter Jobs',
                  ),
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

        return MasonryGridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
          ),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
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
                            bgColor: IndigoColor.c500,
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
