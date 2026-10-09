import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/application_provider.dart';
import '../models/job_application.dart';
import '../constants/colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/glass_card.dart';

class ApplicantApplicationsScreen extends StatefulWidget {
  const ApplicantApplicationsScreen({super.key});

  @override
  State<ApplicantApplicationsScreen> createState() => _ApplicantApplicationsScreenState();
}

class _ApplicantApplicationsScreenState extends State<ApplicantApplicationsScreen> {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Applications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ApplicationProvider>().fetchApplications(),
          ),
        ],
      ),
      body: Consumer<ApplicationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.applications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.applications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.errorMessage!, style: const TextStyle(color: DangerColor.c500)),
                  CustomButton(
                    onPressed: () => provider.fetchApplications(),
                    text: 'Retry',
                    buttonBgColor: BrandColor.c500,
                    fontColor: NeutralColor.c50,
                    width: 120,
                  ),
                ],
              ),
            );
          }

          if (provider.applications.isEmpty) {
            return const Center(child: Text('You haven\'t applied for any jobs yet.'));
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchApplications(),
            
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: provider.applications.length,
              itemBuilder: (context, index) {
                final application = provider.applications[index];
                return _buildApplicationCard(context, application);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildApplicationCard(BuildContext context, JobApplication app) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16.0),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.jobPosition,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        app.companyName,
                        style: TextStyle(color: isDark ? Colors.white70 : NeutralColor.c600),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(app.status),
              ],
            ),
            const SizedBox(height: 16),
            _buildJourneyTimeline(app.status, isDark),
            const Divider(height: 24),
            Text(
              'Applied on: ${app.appliedAt.split('T')[0]}',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
            if (app.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'My Notes: ${app.notes}',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildJourneyTimeline(String status, bool isDark) {
    if (status == 'rejected') {
      return const Text('Application Rejected', style: TextStyle(color: DangerColor.c500, fontWeight: FontWeight.bold));
    }

    final steps = ['pending', 'shortlisted', 'medical', 'visa', 'ticket', 'deployed'];
    final labels = ['Applied', 'Selected', 'Medical', 'Visa', 'Flight', 'Deployed'];
    
    int currentIndex = steps.indexOf(status);
    if (currentIndex == -1) currentIndex = 0; // fallback

    return SizedBox(
      height: 40,
      child: Row(
        children: List.generate(steps.length, (index) {
          final isCompleted = index <= currentIndex;
          final isCurrent = index == currentIndex;
          final color = isCompleted ? SuccessColor.c500 : (isDark ? Colors.grey[800]! : Colors.grey[300]!);

          return Expanded(
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted ? color : Colors.transparent,
                        border: Border.all(
                          color: isCompleted ? color : (isDark ? Colors.grey[600]! : Colors.grey[400]!),
                          width: 2,
                        ),
                      ),
                      child: isCompleted
                          ? const Icon(Icons.check, size: 10, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      labels[index],
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                        color: isCompleted ? (isDark ? Colors.white : Colors.black) : Colors.grey,
                      ),
                    ),
                  ],
                ),
                if (index < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      color: isCompleted && index < currentIndex
                          ? color
                          : (isDark ? Colors.grey[800] : Colors.grey[300]),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String display = status.toUpperCase();
    switch (status) {
      case 'shortlisted':
        color = SuccessColor.c500;
        display = 'SELECTED';
        break;
      case 'medical':
        color = const Color(0xFF10B981);
        display = 'MEDICAL TEST';
        break;
      case 'visa':
        color = const Color(0xFF3B82F6);
        display = 'VISA PROCESSING';
        break;
      case 'ticket':
        color = const Color(0xFF8B5CF6);
        display = 'TICKET BOOKED';
        break;
      case 'deployed':
        color = const Color(0xFF14B8A6);
        display = 'DEPLOYED';
        break;
      case 'rejected':
        color = DangerColor.c500;
        break;
      default:
        color = BrandColor.c500;
        display = 'PENDING';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        display,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
