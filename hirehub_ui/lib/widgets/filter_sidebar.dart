import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import 'custom_button.dart';

class FilterSidebar extends StatefulWidget {
  const FilterSidebar({super.key});

  @override
  State<FilterSidebar> createState() => _FilterSidebarState();
}

class _FilterSidebarState extends State<FilterSidebar> {
  final TextEditingController _locationController = TextEditingController();
  final Map<String, bool> _categories = {
    'IT': false,
    'Design': false,
    'Sales': false,
    'Finance': false,
    'HR': false,
    'Support': false,
    'Marketing': false,
    'Engineering': false,
    'Healthcare': false,
    'Education': false,
  };

  final Map<String, bool> _jobTypes = {
    'Full-time': false,
    'Part-time': false,
    'Contract': false,
    'Remote': false,
  };

  RangeValues _salaryRange = const RangeValues(0, 100000000);

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final selectedCategories = _categories.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    
    final selectedJobTypes = _jobTypes.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    context.read<JobProvider>().searchJobs(
      location: _locationController.text,
      categories: selectedCategories,
      jobTypes: selectedJobTypes,
      minSalary: _salaryRange.start,
      maxSalary: _salaryRange.end,
    );

    // Close drawer if open (Mobile)
    try {
      if (Scaffold.of(context).isEndDrawerOpen) {
        Navigator.pop(context);
      }
    } catch (e) {
      // Not in a scaffold with a drawer (e.g. Desktop side-by-side)
    }
  }

  void _clearAll() {
    setState(() {
      _categories.updateAll((key, value) => false);
      _jobTypes.updateAll((key, value) => false);
      _salaryRange = const RangeValues(0, 100000000);
      _locationController.clear();
    });
    context.read<JobProvider>().clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF191C28); // NeutralColor.c900
    final hintColor = isDark ? Colors.white54 : const Color(0xFF64748B); // NeutralColor.c500

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(right: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  TextButton(
                    onPressed: _clearAll,
                    child: Text('Clear All', style: TextStyle(fontSize: 12, color: const Color(0xFF0EA5E9))),
                  ),
                ],
              ),
            ),
            
            // Filter Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  _buildFilterSection(
                    'Job Category',
                    _categories.keys.map((key) => _buildCheckbox(key, _categories[key]!, (val) {
                      setState(() => _categories[key] = val!);
                    }, textColor)).toList(),
                    textColor,
                  ),
                  const Divider(height: 40),
                  _buildFilterSection(
                    'Job Location',
                    [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextField(
                          controller: _locationController,
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            hintText: 'Search Location',
                            hintStyle: TextStyle(color: hintColor),
                            prefixIcon: Icon(Icons.search, size: 20, color: hintColor),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: EdgeInsets.zero,
                          ),
                          onSubmitted: (_) => _applyFilters(),
                        ),
                      ),
                    ],
                    textColor,
                  ),
                  const Divider(height: 40),
                  _buildFilterSection(
                    'Expected Salary',
                    [
                      RangeSlider(
                        values: _salaryRange,
                        min: 0,
                        max: 100000000,
                        divisions: 20,
                        activeColor: const Color(0xFF0EA5E9),
                        inactiveColor: const Color(0xFF0EA5E9).withOpacity(0.2),
                        labels: RangeLabels(
                          _formatSalary(_salaryRange.start),
                          _formatSalary(_salaryRange.end),
                        ),
                        onChanged: (values) {
                          setState(() => _salaryRange = values);
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_formatSalary(_salaryRange.start), style: TextStyle(color: textColor)),
                            Text('${_formatSalary(_salaryRange.end)}+', style: TextStyle(color: textColor)),
                          ],
                        ),
                      ),
                    ],
                    textColor,
                  ),
                  const Divider(height: 40),
                  _buildFilterSection(
                    'Job Type',
                    _jobTypes.keys.map((key) => _buildCheckbox(key, _jobTypes[key]!, (val) {
                      setState(() => _jobTypes[key] = val!);
                    }, textColor)).toList(),
                    textColor,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            
            // Fixed Bottom Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: CustomButton(
                  onPressed: _applyFilters,
                  text: 'Apply Filters',
                  buttonBgColor: const Color(0xFF0EA5E9),
                  fontColor: Colors.white,
                  elevation: 0,
                  height: 50,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(String title, List<Widget> children, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
            ),
            Icon(Icons.keyboard_arrow_down, size: 20, color: textColor),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildCheckbox(String label, bool value, ValueChanged<bool?> onChanged, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          SizedBox(
            height: 24,
            width: 24,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 14, color: textColor)),
        ],
      ),
    );
  }

  String _formatSalary(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return value.round().toString();
  }
}
