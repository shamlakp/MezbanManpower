import 'package:flutter/material.dart';
import '../models/job_post.dart';
import '../utils/url_helper.dart';
import 'custom_button.dart';

class JobGridCard extends StatefulWidget {
  final JobPost job;
  final VoidCallback? onTap;

  const JobGridCard({
    super.key,
    required this.job,
    this.onTap,
  });

  @override
  State<JobGridCard> createState() => _JobGridCardState();
}

class _JobGridCardState extends State<JobGridCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
    if (widget.onTap != null) widget.onTap!();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: isDark 
                          ? Colors.black.withValues(alpha: _isHovered ? 0.3 : 0.1)
                          : Colors.black.withValues(alpha: _isHovered ? 0.08 : 0.02),
                      blurRadius: _isHovered ? 20 : 10,
                      offset: Offset(0, _isHovered ? 8 : 4),
                    ),
                  ],
                  border: Border.all(
                    color: isDark 
                        ? Colors.white.withValues(alpha: 0.05) 
                        : Colors.black.withValues(alpha: 0.05),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Material(
                  color: Colors.transparent,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final bool isCompact = constraints.maxWidth < 250;
                      return Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isCompact) ...[
                              _buildCompactCardHeader(widget.job, isDark),
                            ] else ...[
                              _buildWideCardHeader(widget.job, isDark),
                            ],
                            
                            const SizedBox(height: 12),
                            _buildCardDetails(widget.job, isDark),
                            
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${DateTime.now().difference(widget.job.createdAt).inDays}d ago',
                                    style: TextStyle(
                                      color: isDark ? Colors.white54 : Colors.grey[500], 
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                _buildViewButton(isDark),
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
          },
        ),
      ),
    );
  }

  Widget _buildCompactCardHeader(JobPost job, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFF2F2F7),
            borderRadius: BorderRadius.circular(16),
          ),
          child: _buildJobImage(job),
        ),
        const SizedBox(height: 10),
        Text(
          job.position,
          style: TextStyle(
            fontSize: 15, 
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black,
            letterSpacing: -0.5,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          job.companyName,
          style: TextStyle(
            color: isDark ? Colors.white60 : Colors.grey[600], 
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildWideCardHeader(JobPost job, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFF2F2F7),
            borderRadius: BorderRadius.circular(16),
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
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black,
                  letterSpacing: -0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                job.companyName,
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.grey[600], 
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardDetails(JobPost job, bool isDark) {
    return Column(
      children: [
        _buildInfoRow(
          Icons.location_on_outlined, 
          job.location, 
          isDark ? Colors.white70 : Colors.grey[700]!,
        ),
        const SizedBox(height: 6),
        _buildInfoRow(
          Icons.payments_outlined, 
          '\$${job.salary}', 
          isDark ? Colors.white70 : Colors.grey[700]!,
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color.withValues(alpha: 0.8)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildViewButton(bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: _isHovered 
            ? (isDark ? Colors.white : Colors.black) 
            : (isDark ? Colors.white12 : const Color(0xFFF2F2F7)),
        borderRadius: BorderRadius.circular(20), // Apple pill button
      ),
      child: Text(
        'View',
        style: TextStyle(
          color: _isHovered 
              ? (isDark ? Colors.black : Colors.white) 
              : (isDark ? Colors.white : Colors.black),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildJobImage(JobPost job) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: (job.image != null && job.image!.isNotEmpty)
          ? Image.network(
              UrlHelper.resolveMediaUrl(job.image!),
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Icon(Icons.business_rounded, size: 24, color: Colors.grey[400]),
            )
          : Icon(Icons.business_rounded, size: 24, color: Colors.grey[400]),
    );
  }
}
