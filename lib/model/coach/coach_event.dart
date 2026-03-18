class CoachEventModel {
  final int eventId;
  final String eventName;
  final DateTime eventDate;
  final String startTime;
  final String endTime;
  final String location;
  final String eventType;
  final String status;
  final int clubId;
  final int createdByUserId;
  final String createdByUsername;
  final List<int> coachIds;
  final DateTime? createdAt;

  CoachEventModel({
    required this.eventId,
    required this.eventName,
    required this.eventDate,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.eventType,
    required this.status,
    required this.clubId,
    required this.createdByUserId,
    required this.createdByUsername,
    required this.coachIds,
    this.createdAt,
  });

  factory CoachEventModel.fromJson(Map<String, dynamic> json) {
    return CoachEventModel(
      eventId: json['eventId'] as int,
      eventName: json['eventName'] as String,
      eventDate: DateTime.parse(json['eventDate']),
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      location: json['location'] as String,
      eventType: json['eventType'] as String,
      status: json['status'] as String,
      clubId: json['clubId'] as int,
      createdByUserId: json['createdByUserId'] as int,
      createdByUsername: json['createdByUsername'] as String,
      coachIds: List<int>.from(json['coachIds']),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'eventName': eventName,
      'eventDate': eventDate.toIso8601String().split('T')[0],
      'startTime': startTime.substring(0, 5),
      'endTime': endTime.substring(0, 5),
      'location': location,
      'eventType': eventType,
      'status': status,
      'clubId': clubId,
      'createdByUserId': createdByUserId,
      'createdByUsername': createdByUsername,
      'coachIds': coachIds,
    };
  }

  // For creating/updating events
  Map<String, dynamic> toCreateUpdateJson() {
    return {
      'eventName': eventName,
      'eventDate': eventDate.toIso8601String().split('T')[0],
      'startTime': startTime.substring(0, 5),
      'endTime': endTime.substring(0, 5),
      'location': location,
      'eventType': eventType,
      'status': status,
      'coachIds': coachIds,
    };
  }
}