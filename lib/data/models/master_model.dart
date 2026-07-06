class MasterModel {
  final String id;
  final String firstName;
  final String lastName;
  final String qualification;
  final double rating;

  MasterModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.qualification,
    required this.rating,
  });

  String get fullName => '$firstName $lastName';

  factory MasterModel.fromJson(Map<String, dynamic> json) {
    return MasterModel(
      id: json['id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      qualification: json['qualification'] as String,
      rating: (json['rating'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'qualification': qualification,
      'rating': rating,
    };
  }
}