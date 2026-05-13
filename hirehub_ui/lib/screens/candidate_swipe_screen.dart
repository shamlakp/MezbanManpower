import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../constants/colors.dart';
import '../widgets/glass_card.dart';

class CandidateSwipeScreen extends StatefulWidget {
  const CandidateSwipeScreen({super.key});

  @override
  State<CandidateSwipeScreen> createState() => _CandidateSwipeScreenState();
}

class _CandidateSwipeScreenState extends State<CandidateSwipeScreen> {
  final CardSwiperController _controller = CardSwiperController();

  final List<Map<String, String>> _candidates = [
    {
      'name': 'Alex Johnson',
      'role': 'Senior Flutter Developer',
      'experience': '5+ Years',
      'skills': 'Flutter, Dart, Firebase, AWS',
      'image': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&h=700&fit=crop'
    },
    {
      'name': 'Sarah Smith',
      'role': 'Product Designer',
      'experience': '3 Years',
      'skills': 'Figma, Adobe XD, UI/UX, Research',
      'image': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=500&h=700&fit=crop'
    },
    {
      'name': 'Michael Chen',
      'role': 'Backend Engineer',
      'experience': '4 Years',
      'skills': 'Node.js, PostgreSQL, Docker, Redis',
      'image': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=500&h=700&fit=crop'
    },
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeutralColor.c50,
      appBar: AppBar(
        title: const Text('Discover Talent', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CardSwiper(
                controller: _controller,
                cardsCount: _candidates.length,
                onSwipe: (previousIndex, currentIndex, direction) {
                  debugPrint('Swiped: $direction');
                  return true;
                },
                cardBuilder: (context, index, horizontalOffsetPercentage, verticalOffsetPercentage) {
                  final candidate = _candidates[index];
                  return _buildCandidateCard(candidate);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSwipeButton(
                    icon: Icons.close_rounded,
                    color: DangerColor.c500,
                    onTap: () => _controller.swipe(CardSwiperDirection.left),
                  ),
                  const SizedBox(width: 40),
                  _buildSwipeButton(
                    icon: Icons.favorite_rounded,
                    color: SuccessColor.c500,
                    onTap: () => _controller.swipe(CardSwiperDirection.right),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCandidateCard(Map<String, String> candidate) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                candidate['image']!,
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      candidate['name']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      candidate['role']!,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: candidate['skills']!
                          .split(', ')
                          .map((skill) => GlassCard(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                borderRadius: BorderRadius.circular(10),
                                opacity: 0.2,
                                child: Text(
                                  skill,
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwipeButton({required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 32),
      ),
    );
  }
}
