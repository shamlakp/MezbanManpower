import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/colors.dart';

class FloatingBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isApplicant;

  const FloatingBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.isApplicant,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = isApplicant 
      ? [
          _NavItem(Icons.search, 'Explore', Icons.search),
          _NavItem(Icons.dashboard_outlined, 'Stats', Icons.dashboard),
          _NavItem(Icons.description_outlined, 'History', Icons.description),
        ]
      : [
          _NavItem(Icons.dashboard_outlined, 'Stats', Icons.dashboard),
          _NavItem(Icons.search, 'Feed', Icons.search),
          _NavItem(Icons.description_outlined, 'Apps', Icons.description),
        ];

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      height: 65, // slightly thinner like iOS dock
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E).withValues(alpha: 0.65) : const Color(0xFFF2F2F7).withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30), // Heavy blur for iOS glass effect
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(items.length, (index) => _buildNavItem(index, items[index], isDark)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, _NavItem item, bool isDark) {
    final isSelected = currentIndex == index;
    final activeColor = isDark ? Colors.white : Colors.black;
    final inactiveColor = isDark ? const Color(0xFF8E8E93) : const Color(0xFF8E8E93); // iOS System Gray

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        color: Colors.transparent, // Removed pill shape
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
              child: Icon(
                isSelected ? item.activeIcon : item.icon, // Filled when active, outlined when inactive
                key: ValueKey<bool>(isSelected),
                color: isSelected ? activeColor : inactiveColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                color: isSelected ? activeColor : inactiveColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 10,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final IconData activeIcon;
  _NavItem(this.icon, this.label, this.activeIcon);
}
