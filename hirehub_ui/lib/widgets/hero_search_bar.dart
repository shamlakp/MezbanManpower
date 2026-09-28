import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icons_plus/icons_plus.dart';
import 'dart:ui';
import '../providers/job_provider.dart';
import '../constants/colors.dart';

class HeroSearchBar extends StatefulWidget {
  const HeroSearchBar({super.key});

  @override
  State<HeroSearchBar> createState() => _HeroSearchBarState();
}

class _HeroSearchBarState extends State<HeroSearchBar> {
  final TextEditingController _keywordController = TextEditingController();
  bool _isFocused = false;

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  void _performSearch(BuildContext context) {
    final jobProvider = context.read<JobProvider>();
    jobProvider.searchJobs(
      keyword: _keywordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: FocusScope(
        child: Focus(
          onFocusChange: (focus) => setState(() => _isFocused = focus),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: _isFocused 
                      ? BrandColor.c500.withValues(alpha: 0.2) 
                      : (isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.05)),
                  blurRadius: _isFocused ? 20 : 10,
                  offset: const Offset(0, 4),
                  spreadRadius: _isFocused ? 2 : 0,
                ),
              ],
              border: Border.all(
                color: _isFocused 
                    ? BrandColor.c500.withValues(alpha: 0.5) 
                    : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
                width: 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: TextField(
                  controller: _keywordController,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search for jobs, skills, or companies...',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black45,
                      fontSize: 15,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 12.0),
                      child: Icon(
                        Bootstrap.search, 
                        color: _isFocused ? BrandColor.c500 : (isDark ? Colors.white54 : Colors.black45),
                        size: 20,
                      ),
                    ),
                    suffixIcon: _keywordController.text.isNotEmpty ? IconButton(
                      icon: Icon(Icons.close, color: isDark ? Colors.white54 : Colors.black45, size: 20),
                      onPressed: () {
                        _keywordController.clear();
                        _performSearch(context);
                        setState(() {});
                      },
                    ) : null,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  ),
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _performSearch(context),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}