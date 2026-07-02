import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';

class HeroSearchBar extends StatefulWidget {
  const HeroSearchBar({super.key});

  @override
  State<HeroSearchBar> createState() => _HeroSearchBarState();
}

class _HeroSearchBarState extends State<HeroSearchBar> {
  final TextEditingController _keywordController = TextEditingController();

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
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFF767680).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextField(
          controller: _keywordController,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 17,
          ),
          decoration: InputDecoration(
            hintText: 'Search',
            hintStyle: TextStyle(
              color: isDark ? const Color(0xFFEBEBF5).withValues(alpha: 0.6) : const Color(0xFF3C3C43).withValues(alpha: 0.6),
              fontSize: 17,
            ),
            prefixIcon: Icon(
              Icons.search, 
              color: isDark ? const Color(0xFFEBEBF5).withValues(alpha: 0.6) : const Color(0xFF3C3C43).withValues(alpha: 0.6),
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
          onSubmitted: (_) => _performSearch(context),
        ),
      ),
    );
  }

}
 