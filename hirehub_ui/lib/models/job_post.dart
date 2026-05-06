
class JobPost {
  final int id;
  final String position;
  final String companyName;
  final int noOfVacancies;
  final String location;
  final String salary;
  final bool isApproved;
  final String? image;
  
  // Additional Details
  final String workingTime;
  final String workingDays;
  final String responsibilities;
  final String qualifications;
  final String benefits;
  final int annualLeave;

  // New Fields
  final String industry;
  final String accommodation;
  final String meals;
  final String category;
  final DateTime createdAt;

  JobPost({
    required this.id,
    required this.position,
    required this.companyName,
    required this.noOfVacancies,
    required this.location,
    required this.salary,
    required this.isApproved,
    required this.createdAt,
    this.image,
    this.workingTime = '',
    this.workingDays = '',
    this.responsibilities = '',
    this.qualifications = '',
    this.benefits = '',
    this.annualLeave = 0,
    this.industry = '',
    this.accommodation = '',
    this.meals = '',
    this.category = '',
  });

  factory JobPost.fromJson(Map<String, dynamic> json) {
    return JobPost(
      id: json['id'] ?? 0,
      position: json['position'] ?? 'No Position',
      companyName: json['company_name'] ?? 'Unknown Company',
      noOfVacancies: json['no_of_vacancies'] ?? 0,
      location: json['location'] ?? '',
      salary: json['salary'] ?? '',
      isApproved: json['is_approved'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      image: json['image'],
      workingTime: json['working_time'] ?? '',
      workingDays: json['working_days'] ?? '',
      responsibilities: json['responsibilities'] ?? '',
      qualifications: json['qualifications'] ?? '',
      benefits: json['benefits'] ?? '',
      annualLeave: json['annual_leave'] ?? 0,
      industry: json['industry'] ?? '',
      accommodation: json['accommodation'] ?? '',
      meals: json['meals'] ?? '',
      category: json['category'] ?? '',
    );
  }
}
