class ClubMember {
  final int memberId;
  final int userId;
  final String dob;
  final String username;
  final String email;
  final String gender;
  final String medicalNotes;
  final DateTime createdAt;

  ClubMember({
    required this.memberId,
    required this.userId,
    required this.dob,
    required this.username,
    required this.email,
    required this.gender,
    required this.medicalNotes,
    required this.createdAt,
  });

  factory ClubMember.fromJson(Map<String, dynamic> json) {
    return ClubMember(
      memberId: json['memberId'] as int,
      userId: json['userId'] as int,
      dob: json['dob'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      gender: json['gender'] as String,
      medicalNotes: json['medicalNotes'] as String,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'memberId': memberId,
      'userId': userId,
      'dob': dob,
      'username': username,
      'email': email,
      'gender': gender,
      'medicalNotes': medicalNotes,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}