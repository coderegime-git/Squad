// model/coach/coach_event.dart
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
      eventId: json['eventId'] ?? 0,
      eventName: json['eventName'] ?? '',
      eventDate: json['eventDate'] != null
          ? DateTime.parse(json['eventDate'])
          : DateTime.now(),
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      location: json['location'] ?? '',
      eventType: json['eventType'] ?? '',
      status: json['status'] ?? '',
      clubId: json['clubId'] ?? 0,
      createdByUserId: json['createdByUserId'] ?? 0,
      createdByUsername: json['createdByUsername'] ?? '',
      coachIds: json['coachIds'] != null
          ? List<int>.from(json['coachIds'])
          : [],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'eventName': eventName,
      'eventDate': eventDate.toIso8601String().split('T')[0],
      'startTime': startTime,
      'endTime': endTime,
      'location': location,
      'eventType': eventType,
      'status': status,
      'clubId': clubId,
      'createdByUserId': createdByUserId,
      'createdByUsername': createdByUsername,
      'coachIds': coachIds,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}