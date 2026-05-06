import '../clubAdmin/get_event_details.dart';

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
  final int? activityId;
  final String? activityName;
  final int createdByUserId;
  final String? createdByUsername;
  final List<EventCoach> coaches; // ← replaces coachIds
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
    this.activityId,
    this.activityName,
    required this.createdByUserId,
    this.createdByUsername,
    required this.coaches,
    this.createdAt,
  });

  // Convenience getter — keeps all existing coachIds references working
  List<int> get coachIds => coaches.map((c) => c.coachId).toList();

  // Convenience getter for display
  String get coachNamesDisplay =>
      coaches.isEmpty ? 'No coaches' : coaches.map((c) => c.coachName).join(', ');

  factory CoachEventModel.fromJson(Map<String, dynamic> json) {
    return CoachEventModel(
      eventId: json['eventId'] as int? ?? 0,
      eventName: json['eventName'] as String? ?? '',
      eventDate: json['eventDate'] != null
          ? DateTime.parse(json['eventDate'])
          : DateTime.now(),
      startTime: json['startTime'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
      location: json['location'] as String? ?? '',
      eventType: json['eventType'] as String? ?? '',
      status: json['status'] as String? ?? '',
      clubId: json['clubId'] as int? ?? 0,
      activityId: json['activityId'] as int?,
      activityName: json['activityName'] as String?,
      createdByUserId: json['createdByUserId'] as int? ?? 0,
      createdByUsername: json['createdByUsername'] as String?,
      // Parse coaches array (new API shape)
      coaches: (json['coaches'] as List<dynamic>? ?? [])
          .map((c) => EventCoach.fromJson(c as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
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
      'activityId': activityId,
      'activityName': activityName,
      'createdByUserId': createdByUserId,
      'createdByUsername': createdByUsername,
      'coaches': coaches.map((c) => c.toJson()).toList(),
    };
  }

  Map<String, dynamic> toCreateUpdateJson() {
    return {
      'eventName': eventName,
      'eventDate': eventDate.toIso8601String().split('T')[0],
      'startTime': startTime,
      'endTime': endTime,
      'location': location,
      'eventType': eventType,
      'status': status,
      'coachIds': coachIds,
    };
  }
}