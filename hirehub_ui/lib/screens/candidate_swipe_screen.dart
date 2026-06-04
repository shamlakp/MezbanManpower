import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../models/job_application.dart';
import '../providers/application_provider.dart';
import '../widgets/glass_card.dart';
import '../utils/url_helper.dart';

class CandidateSwipeScreen extends StatefulWidget {
  const CandidateSwipeScreen({super.key});

  @override
  State<CandidateSwipeScreen> createState() => _CandidateSwipeScreenState();
}

class _CandidateSwipeScreenState extends State<CandidateSwipeScreen> {
  final CardSwiperController _controller = CardSwiperController();
  List<JobApplication> _pendingApplicants = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  String? _lastAction; // 'shortlisted' or 'rejected'

  @override
  void initState() {
    super.initState();
    _loadApplicants();
  }

  Future<void> _loadApplicants() async {
    final provider = context.read<ApplicationProvider>();
    await provider.fetchApplications();
    if (mounted) {
      setState(() {
        // Only show pending applicants — these are the ones to decide on
        _pendingApplicants = provider.applications
            .where((a) => a.status == 'pending')
            .toList();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<bool> _handleSwipe(int prev, int? curr, CardSwiperDirection dir) async {
    final app = _pendingApplicants[prev];
    final provider = context.read<ApplicationProvider>();

    if (dir == CardSwiperDirection.right) {
      await provider.updateApplicationStatus(app.id, 'shortlisted');
      if (mounted) setState(() => _lastAction = 'shortlisted');
    } else if (dir == CardSwiperDirection.left) {
      await provider.updateApplicationStatus(app.id, 'rejected');
      if (mounted) setState(() => _lastAction = 'rejected');
    }

    if (mounted) setState(() => _currentIndex = curr ?? prev + 1);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeutralColor.c50,
      appBar: AppBar(
        title: const Text(
          'Discover Talent',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: BrandColor.c500))
          : _pendingApplicants.isEmpty
              ? _buildEmptyState()
              : SafeArea(
                  child: Column(
                    children: [
                      // Progress indicator
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_pendingApplicants.length} pending applicants',
                              style: const TextStyle(
                                color: NeutralColor.c500,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            if (_lastAction != null)
                              _buildActionBadge(_lastAction!),
                          ],
                        ),
                      ),
                      Expanded(
                        child: CardSwiper(
                          controller: _controller,
                          cardsCount: _pendingApplicants.length,
                          onSwipe: _handleSwipe,
                          numberOfCardsDisplayed:
                              _pendingApplicants.length > 2 ? 3 : _pendingApplicants.length,
                          backCardOffset: const Offset(0, 24),
                          scale: 0.9,
                          cardBuilder: (context, index, hOffset, vOffset) {
                            return _buildApplicantCard(
                              _pendingApplicants[index],
                              hOffset / 100.0, // convert int % to -1.0..1.0 double
                            );
                          },
                        ),
                      ),
                      // Action buttons
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 28.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildSwipeButton(
                              icon: Icons.close_rounded,
                              color: DangerColor.c500,
                              label: 'Reject',
                              onTap: () =>
                                  _controller.swipe(CardSwiperDirection.left),
                            ),
                            const SizedBox(width: 48),
                            _buildSwipeButton(
                              icon: Icons.check_rounded,
                              color: SuccessColor.c500,
                              label: 'Shortlist',
                              onTap: () =>
                                  _controller.swipe(CardSwiperDirection.right),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildApplicantCard(JobApplication app, double hOffset) {
    final details = app.applicantDetails ?? {};
    final skills = (details['skills'] as String?)?.split(',') ?? [];
    final bio = details['bio'] as String? ?? 'No bio provided.';
    final phone = details['phone'] as String? ?? '';
    final email = details['email'] as String? ?? '';

    // Tint the card based on swipe direction
    Color? tintColor;
    if (hOffset > 0.2) tintColor = SuccessColor.c500.withOpacity(0.15);
    if (hOffset < -0.2) tintColor = DangerColor.c500.withOpacity(0.15);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            // Main content
            Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar + name row
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: BrandColor.c500.withOpacity(0.1),
                        backgroundImage: details['profile_image'] != null
                            ? NetworkImage(UrlHelper.resolveMediaUrl(details['profile_image']))
                            : null,
                        child: details['profile_image'] == null
                            ? Text(
                                app.applicantName.isNotEmpty
                                    ? app.applicantName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: BrandColor.c500,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              app.applicantName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: NeutralColor.c900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Applied for: ${app.jobPosition}',
                              style: const TextStyle(
                                color: BrandColor.c500,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Company
                  _infoRow(Icons.business_outlined, app.companyName),
                  if (email.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _infoRow(Icons.email_outlined, email),
                  ],
                  if (phone.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _infoRow(Icons.phone_outlined, phone),
                  ],

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Bio
                  Text(
                    'About',
                    style: TextStyle(
                      color: NeutralColor.c500,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    bio,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: NeutralColor.c700,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),

                  if (skills.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Skills',
                      style: TextStyle(
                        color: NeutralColor.c500,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: skills
                          .take(5)
                          .map(
                            (s) => GlassCard(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              borderRadius: BorderRadius.circular(10),
                              opacity: 0.06,
                              child: Text(
                                s.trim(),
                                style: const TextStyle(
                                  color: NeutralColor.c900,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Applied date
                  Text(
                    'Applied: ${app.appliedAt.split('T')[0]}',
                    style: const TextStyle(
                      color: NeutralColor.c400,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Swipe tint overlay
            if (tintColor != null)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: tintColor,
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
              ),

            // Swipe hint label
            if (hOffset > 0.3)
              Positioned(
                top: 32,
                left: 24,
                child: _buildHintLabel('SHORTLIST', SuccessColor.c500),
              ),
            if (hOffset < -0.3)
              Positioned(
                top: 32,
                right: 24,
                child: _buildHintLabel('REJECT', DangerColor.c500),
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: NeutralColor.c400),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
                color: NeutralColor.c600,
                fontSize: 13,
                fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildHintLabel(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 2),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 13, fontWeight: FontWeight.w900),
      ),
    );
  }

  Widget _buildActionBadge(String action) {
    final isShortlist = action == 'shortlisted';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color:
            (isShortlist ? SuccessColor.c500 : DangerColor.c500).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isShortlist ? '✓ Shortlisted' : '✗ Rejected',
        style: TextStyle(
          color: isShortlist ? SuccessColor.c500 : DangerColor.c500,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSwipeButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w700, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: BrandColor.c500.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.people_outline_rounded,
                  size: 56, color: BrandColor.c500),
            ),
            const SizedBox(height: 24),
            const Text(
              'All caught up!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: NeutralColor.c900,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'No pending applicants to review.\nCheck back after new applications arrive.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: NeutralColor.c500, fontSize: 14, height: 1.6),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isLoading = true;
                });
                _loadApplicants();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: BrandColor.c500,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Refresh',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
