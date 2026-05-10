
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/application_provider.dart';
import '../models/job_application.dart';

class RecruiterApplicationsScreen extends StatefulWidget {
  const RecruiterApplicationsScreen({super.key});

  @override
  State<RecruiterApplicationsScreen> createState() => _RecruiterApplicationsScreenState();
}

class _RecruiterApplicationsScreenState extends State<RecruiterApplicationsScreen> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<ApplicationProvider>().fetchApplications();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final neutralBg = isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFB);
    final textMain = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final textSub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: neutralBg,
      appBar: AppBar(
        title: Text(
          'Applicants', 
          style: TextStyle(fontWeight: FontWeight.w900, color: textMain, fontSize: 24, letterSpacing: -0.8)
        ),
        backgroundColor: neutralBg,
        elevation: 0,
        centerTitle: false,
        leading: BackButton(color: textMain),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: textSub),
            onPressed: () => context.read<ApplicationProvider>().fetchApplications(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterBar(isDark, textMain, textSub),
          Expanded(
            child: Consumer<ApplicationProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.applications.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)));
                }

                if (provider.errorMessage != null && provider.applications.isEmpty) {
                  return _buildErrorState(provider);
                }

                final filteredApps = _getFilteredApplications(provider.applications);

                if (filteredApps.isEmpty) {
                  return _buildEmptyState(textMain, textSub);
                }

                return RefreshIndicator(
                  onRefresh: () => provider.fetchApplications(),
                  color: const Color(0xFF6366F1),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                    itemCount: filteredApps.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 20),
                    itemBuilder: (context, index) {
                      final application = filteredApps[index];
                      return _buildModernAppCard(context, application, provider, isDark, textMain, textSub);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(bool isDark, Color textMain, Color textSub) {
    final filters = [
      {'label': 'All', 'value': 'all'},
      {'label': 'Pending', 'value': 'pending'},
      {'label': 'Shortlisted', 'value': 'shortlisted'},
      {'label': 'Rejected', 'value': 'rejected'},
    ];

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter['value'];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = filter['value']!),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? (isDark ? Colors.white : const Color(0xFF0F172A)) : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? (isDark ? Colors.white : const Color(0xFF0F172A)) : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  ),
                ),
                child: Center(
                  child: Text(
                    filter['label']!,
                    style: TextStyle(
                      color: isSelected ? (isDark ? Colors.black : Colors.white) : textSub,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<JobApplication> _getFilteredApplications(List<JobApplication> apps) {
    if (_selectedFilter == 'all') return apps;
    return apps.where((app) => app.status == _selectedFilter).toList();
  }

  Widget _buildModernAppCard(BuildContext context, JobApplication app, ApplicationProvider provider, bool isDark, Color textMain, Color textSub) {
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final surfaceColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF8FAFC);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.02),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: surfaceColor,
                      child: Text(
                        app.applicantName[0].toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF6366F1)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            app.applicantName,
                            style: TextStyle(
                              fontSize: 18, 
                              fontWeight: FontWeight.w800,
                              color: textMain,
                            ),
                          ),
                          Text(
                            app.jobPosition,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: textSub,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildMiniBadge(app.status),
                  ],
                ),
                if (app.notes.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor),
                    ),
                    child: Text(
                      app.notes,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 6),
                    Text(
                      'Applied ${app.appliedAt.split('T')[0]}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    if (app.status == 'pending')
                      Row(
                        children: [
                          _buildLinkBtn('Reject', Colors.red, () => _updateStatus(context, app.id, 'rejected', provider)),
                          const SizedBox(width: 16),
                          _buildLinkBtn('Shortlist', const Color(0xFF6366F1), () => _updateStatus(context, app.id, 'shortlisted', provider)),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkBtn(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 14),
      ),
    );
  }

  Widget _buildMiniBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'shortlisted': color = const Color(0xFF16A34A); break;
      case 'rejected': color = const Color(0xFFDC2626); break;
      default: color = const Color(0xFF2563EB);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildEmptyState(Color textMain, Color textSub) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: textSub.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'No applications yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textMain),
          ),
          const SizedBox(height: 8),
          Text(
            'Try changing your filter or check back later.',
            style: TextStyle(color: textSub),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ApplicationProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(provider.errorMessage!),
          TextButton(onPressed: () => provider.fetchApplications(), child: const Text('Retry')),
        ],
      ),
    );
  }

  void _updateStatus(BuildContext context, int id, String status, ApplicationProvider provider) async {
    final success = await provider.updateApplicationStatus(id, status);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Applicant ${status == 'shortlisted' ? 'shortlisted' : 'rejected'}'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    }
  }
}
