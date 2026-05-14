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
                        style: TextStyle(color: NeutralColor.c600),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(app.status),
              ],
            ),
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

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'shortlisted':
        color = SuccessColor.c500;
        break;
      case 'rejected':
        color = DangerColor.c500;
        break;
      default:
        color = BrandColor.c500;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
