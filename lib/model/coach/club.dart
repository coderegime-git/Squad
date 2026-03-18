class Club {
  final int clubId;
  final String clubName;
  final String description;
  final DateTime? createdAt;

  Club({
    required this.clubId,
    required this.clubName,
    required this.description,
    this.createdAt,
  });

  // Factory method to create Club from JSON
  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      clubId: json['clubId'] as int,
      clubName: json['clubName'] as String,
      description: json['description'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  // Method to convert Club to JSON
  Map<String, dynamic> toJson() {
    return {
      'clubId': clubId,
      'clubName': clubName,
      'description': description,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}