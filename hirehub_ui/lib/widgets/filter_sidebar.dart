import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';

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
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.grey[200]!)),
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
                  const Text(
                    'Filters',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: _clearAll,
                    child: const Text('Clear All', style: TextStyle(fontSize: 12)),
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
                    })).toList(),
                  ),
                  const Divider(height: 40),
                  _buildFilterSection(
                    'Job Location',
                    [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextField(
                          controller: _locationController,
                          decoration: InputDecoration(
                            hintText: 'Search Location',
                            prefixIcon: const Icon(Icons.search, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: EdgeInsets.zero,
                          ),
                          onSubmitted: (_) => _applyFilters(),
                        ),
                      ),
                    ],
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
                            Text(_formatSalary(_salaryRange.start)),
                            Text('${_formatSalary(_salaryRange.end)}+'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 40),
                  _buildFilterSection(
                    'Job Type',
                    _jobTypes.keys.map((key) => _buildCheckbox(key, _jobTypes[key]!, (val) {
                      setState(() => _jobTypes[key] = val!);
                    })).toList(),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            
            // Fixed Bottom Button (Now scrolls with content)
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0EA5E9),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Icon(Icons.keyboard_arrow_down, size: 20),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildCheckbox(String label, bool value, ValueChanged<bool?> onChanged) {
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
          Text(label, style: const TextStyle(fontSize: 14)),
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
