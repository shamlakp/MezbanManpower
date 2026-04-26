import 'package:flutter/material.dart';
import '../models/job_post.dart';
import '../utils/url_helper.dart';

class JobGridCard extends StatelessWidget {
  final JobPost job;
  final VoidCallback? onTap;

  const JobGridCard({
    super.key,
    required this.job,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isCompact = constraints.maxWidth < 250;
              return Padding(
                padding: const EdgeInsets.all(12.0), // slightly tighter
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Layout change based on width
                    if (isCompact) ...[
                      // Compact Portrait Mode
                      _buildCompactCardHeader(job),
                    ] else ...[
                      // Desktop/Wide Mode
                      _buildWideCardHeader(job),
                    ],
                    
                    const SizedBox(height: 12),
                    _buildCardDetails(job),
                    
                    const Spacer(),
                    const Divider(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${DateTime.now().difference(job.createdAt).inDays}d ago',
                            style: TextStyle(color: Colors.grey[500], fontSize: 10),
                          ),
                        ),
                        _buildViewButton(onTap),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCompactCardHeader(JobPost job) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: _buildJobImage(job),
        ),
        const SizedBox(height: 12),
        Text(
          job.position,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          job.companyName,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildWideCardHeader(JobPost job) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: _buildJobImage(job),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                job.position,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                job.companyName,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardDetails(JobPost job) {
    return Column(
      children: [
        _buildInfoRow(Icons.location_on_outlined, job.location, Colors.grey[700]!),
        const SizedBox(height: 4),
        _buildInfoRow(Icons.payments_outlined, '\$${job.salary}', Colors.green[800]!),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color.withValues(alpha: 0.7)),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildViewButton(VoidCallback? onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF673AB7),
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: Size.zero,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text('View', style: TextStyle(fontSize: 11)),
    );
  }

  Widget _buildJobImage(JobPost job) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: (job.image != null && job.image!.isNotEmpty)
          ? Image.network(
              _getImageUrl(job.image!),
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Icon(Icons.business, size: 24, color: Colors.grey[400]),
            )
          : Icon(Icons.business, size: 24, color: Colors.grey[400]),
    );
  }

  String _getImageUrl(String imagePath) {
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    // Ensure the path starts with /
    final path = imagePath.startsWith('/') ? imagePath : '/$imagePath';
    final url = '${UrlHelper.getBaseUrl()}$path';
    debugPrint('Constructed image URL: $url');
    return url;
  }
}
