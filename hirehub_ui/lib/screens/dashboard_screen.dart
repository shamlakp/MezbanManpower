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
import '../widgets/custom_button.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'job_detail_screen.dart';
import 'recruiter_profile_screen.dart';
import 'recruiter_applications_screen.dart';
import 'recruiter_dashboard_screen.dart';

import 'applicant_applications_screen.dart';
import 'applicant_dashboard_screen.dart';
import 'admin_profile_screen.dart';
import 'applicant_documents_screen.dart';
import 'create_job_screen.dart';

import '../utils/location_helper.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:icons_plus/icons_plus.dart';

const String baseUrl = "https://shamlashammu.pythonanywhere.com";

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
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final platform = context.watch<PlatformProvider>();
    final username = auth.userData?['username'] ?? 'User';
    debugPrint('DashboardScreen: userData: ${auth.userData}');
    debugPrint('DashboardScreen: Profile Image = ${auth.userData?['profile']?['profile_image']}');
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
                            MaterialPageRoute(builder: (_) => userType == 'applicant' ? ApplicantDashboardScreen(
                              onBrowseJobs: () {
                                Navigator.pop(context);
                                setState(() => _currentIndex = 0);
                              },
                            ) : const RecruiterDashboardScreen()),
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
                      } else if (value == 'theme') {
                        platform.toggleTheme();
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
                    PopupMenuItem(
                      value: 'theme',
                      child: Row(
                        children: [
                          Icon(
                            platform.themeMode == ThemeMode.light
                                ? Icons.dark_mode_outlined
                                : Icons.light_mode_outlined,
                            color: NeutralColor.c600,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            platform.themeMode == ThemeMode.light
                                ? 'Dark Mode'
                                : 'Light Mode',
                          ),
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
                    backgroundImage: auth.userData?['profile']?['profile_image'] != null
                        ? NetworkImage(UrlHelper.resolveMediaUrl(auth.userData!['profile']['profile_image']))
                        : null,
                    child: auth.userData?['profile']?['profile_image'] == null
                        ? Text(
                            username[0].toUpperCase(),
                            style: const TextStyle(color: BrandColor.c500, fontWeight: FontWeight.bold),
                          )
                        : null,
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
        case 1: return ApplicantDashboardScreen(
                  showAppBar: false,
                  onBrowseJobs: () => setState(() => _currentIndex = 0),
                ); // Hide appbar when in bottom nav
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
    final auth = context.read<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = BrandColor.c500;
    
    return Drawer(
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
                  backgroundImage: auth.userData?['profile']?['profile_image'] != null
                      ? NetworkImage(UrlHelper.resolveMediaUrl(auth.userData!['profile']['profile_image']))
                      : null,
                  child: auth.userData?['profile']?['profile_image'] == null
                      ? Text(
                          username[0].toUpperCase(),
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primary),
                        )
                      : null,
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
                        MaterialPageRoute(builder: (_) => userType == 'applicant' ? ApplicantDashboardScreen(
                          onBrowseJobs: () {
                            Navigator.pop(context);
                            setState(() => _currentIndex = 0);
                          },
                        ) : const RecruiterDashboardScreen()),
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
                if (userType == 'applicant')
                  _buildDrawerItem(
                    icon: Icons.badge_outlined,
                    title: 'My Documents',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ApplicantDocumentsScreen()),
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
          
          // 2. Categories Section (Glassmorphism chips)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Top Destinations',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(foregroundColor: BrandColor.c500, padding: EdgeInsets.zero, minimumSize: const Size(0, 0)),
                  child: const Text('See All', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: Consumer<JobProvider>(
              builder: (context, provider, child) {
                // Get unique locations from available jobs
                final uniqueLocations = provider.jobs
                    .map((job) => job.location.trim())
                    .where((loc) => loc.isNotEmpty)
                    .toSet()
                    .toList();

                // Default list in case there are no jobs yet
                final defaultCountries = ['Saudi Arabia', 'UAE', 'Qatar', 'Kuwait', 'Oman', 'Bahrain'];
                
                final displayCountries = uniqueLocations.isNotEmpty ? uniqueLocations : defaultCountries;

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: displayCountries.length,
                  itemBuilder: (context, index) {
                    final countryName = displayCountries[index];
                    final flagAndColor = _getCountryFlagAndColor(countryName);
                    final flag = flagAndColor.key;
                    final color = flagAndColor.value;
                    
                    final isDark = Theme.of(context).brightness == Brightness.dark;
                    
                    return GestureDetector(
                      onTap: () {
                        provider.clearSearch(); // Clear other filters first
                        provider.searchJobs(location: countryName);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Showing jobs in $countryName'),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: color,
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: Column(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.05)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(flag, style: const TextStyle(fontSize: 28)),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              countryName.length > 12 ? '${countryName.substring(0, 10)}...' : countryName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white70 : NeutralColor.c800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
          CustomButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
            text: 'Sign In',
            buttonBgColor: BrandColor.c500,
            fontColor: NeutralColor.c50,
            width: 150,
            height: 45,
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
                CustomButton(
                  onPressed: () => provider.fetchJobs(),
                  buttonBgColor: BrandColor.c500,
                  fontColor: Colors.white,
                  text: 'Try Again',
                  width: 150,
                  height: 45,
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

        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            height: 140, // Compact height
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: isDark 
                    ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                    : [const Color(0xFF334155), const Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black.withValues(alpha: 0.5) : const Color(0xFF334155).withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Decorative circles
                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -40,
                  left: 20,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Accelerate Your Career',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Connect with top employers today.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          _buildModernCircleIcon(
                            icon: Bootstrap.telephone_fill,
                            color: const Color(0xFF2563EB),
                            bgColor: Colors.white,
                            onTap: () => launchUrl(Uri.parse('tel:${settings.phoneNumber}')),
                          ),
                          const SizedBox(width: 12),
                          _buildModernCircleIcon(
                            icon: Bootstrap.whatsapp,
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

  Widget _buildModernCircleIcon({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  MapEntry<String, Color> _getCountryFlagAndColor(String location) {
    final loc = location.toLowerCase();
    if (loc.contains('saudi') || loc.contains('ksa')) return const MapEntry('🇸🇦', Color(0xFF006C35));
    if (loc.contains('uae') || loc.contains('emirates') || loc.contains('dubai') || loc.contains('abu dhabi')) return const MapEntry('🇦🇪', Color(0xFF00732F));
    if (loc.contains('qatar') || loc.contains('doha')) return const MapEntry('🇶🇦', Color(0xFF8A1538));
    if (loc.contains('kuwait')) return const MapEntry('🇰🇼', Color(0xFF007A3D));
    if (loc.contains('oman') || loc.contains('muscat')) return const MapEntry('🇴🇲', Color(0xFFDB161B));
    if (loc.contains('bahrain') || loc.contains('manama')) return const MapEntry('🇧🇭', Color(0xFFCE1126));
    if (loc.contains('malaysia') || loc.contains('kuala lumpur')) return const MapEntry('🇲🇾', Color(0xFF012C7A));
    if (loc.contains('singapore')) return const MapEntry('🇸🇬', Color(0xFFED2939));
    if (loc.contains('usa') || loc.contains('united states') || loc.contains('america')) return const MapEntry('🇺🇸', Color(0xFF3C3B6E));
    if (loc.contains('uk') || loc.contains('united kingdom') || loc.contains('london') || loc.contains('england')) return const MapEntry('🇬🇧', Color(0xFF012169));
    if (loc.contains('canada') || loc.contains('toronto')) return const MapEntry('🇨🇦', Color(0xFFFF0000));
    if (loc.contains('australia') || loc.contains('sydney')) return const MapEntry('🇦🇺', Color(0xFF00008B));
    if (loc.contains('india') || loc.contains('delhi') || loc.contains('mumbai')) return const MapEntry('🇮🇳', Color(0xFFFF9933));
    if (loc.contains('pakistan') || loc.contains('karachi') || loc.contains('lahore')) return const MapEntry('🇵🇰', Color(0xFF006600));
    if (loc.contains('bangladesh') || loc.contains('dhaka')) return const MapEntry('🇧🇩', Color(0xFF006A4E));
    if (loc.contains('nepal') || loc.contains('kathmandu')) return const MapEntry('🇳🇵', Color(0xFFDC143C));
    if (loc.contains('sri lanka') || loc.contains('colombo')) return const MapEntry('🇱🇰', Color(0xFFFFBE29));
    if (loc.contains('philippines') || loc.contains('manila')) return const MapEntry('🇵🇭', Color(0xFF0038A8));
    if (loc.contains('indonesia') || loc.contains('jakarta')) return const MapEntry('🇮🇩', Color(0xFFFF0000));
    if (loc.contains('vietnam') || loc.contains('hanoi')) return const MapEntry('🇻🇳', Color(0xFFDA251D));
    if (loc.contains('thailand') || loc.contains('bangkok')) return const MapEntry('🇹🇭', Color(0xFFA51931));
    if (loc.contains('japan') || loc.contains('tokyo')) return const MapEntry('🇯🇵', Color(0xFFBC002D));
    if (loc.contains('korea') || loc.contains('seoul')) return const MapEntry('🇰🇷', Color(0xFF0047A0));
    if (loc.contains('china') || loc.contains('beijing')) return const MapEntry('🇨🇳', Color(0xffee1c25));
    if (loc.contains('germany') || loc.contains('berlin')) return const MapEntry('🇩🇪', Color(0xFFFFCE00));
    if (loc.contains('france') || loc.contains('paris')) return const MapEntry('🇫🇷', Color(0xFF002395));
    
    // Default fallback
    return const MapEntry('🌍', BrandColor.c500);
  }
}
