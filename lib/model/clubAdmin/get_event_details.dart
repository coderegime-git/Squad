import 'dart:convert';

GetEventDetails GetEventDetailsFromJson(String data) =>
    GetEventDetails.fromJson(json.decode(data));

class GetEventDetails {
  GetEventDetails({
    required this.success,
    required this.message,
    required this.data,
    this.errorCode,
    required this.timestamp,
  });
  late final bool success;
  late final String message;
  late final List<Data> data;
  late final Null errorCode;
  late final String timestamp;

  GetEventDetails.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = List.from(json['data']).map((e) => Data.fromJson(e)).toList();
    errorCode = null;
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['success'] = success;
    _data['message'] = message;
    _data['data'] = data.map((e) => e.toJson()).toList();
    _data['errorCode'] = errorCode;
    _data['timestamp'] = timestamp;
    return _data;
  }
}

// NEW: small model for coach inside event
class EventCoach {
  final int coachId;
  final String coachName;

  EventCoach({required this.coachId, required this.coachName});

  factory EventCoach.fromJson(Map<String, dynamic> json) => EventCoach(
    coachId: json['coachId'] ?? 0,
    coachName: json['coachName'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'coachId': coachId,
    'coachName': coachName,
  };
}

class Data {
  Data({
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
    required this.createdByUsername,
    required this.coaches,       // ← now List<EventCoach>
    required this.createdAt,
  });

  late final int eventId;
  late final String eventName;
  late final String eventDate;
  late final String startTime;
  late final String endTime;
  late final String location;
  late final String eventType;
  late final String status;
  late final int clubId;
  late final int? activityId;       // nullable — API sends null
  late final String? activityName;  // nullable
  late final int createdByUserId;
  late final String createdByUsername;
  late final List<EventCoach> coaches; // ← replaces coachIds
  late final String createdAt;

  // Convenience getter so existing coachIds references keep working
  List<int> get coachIds => coaches.map((c) => c.coachId).toList();

  // Convenience getter for display
  String get coachNamesDisplay =>
      coaches.isEmpty ? 'No coaches' : coaches.map((c) => c.coachName).join(', ');

  Data.fromJson(Map<String, dynamic> json) {
    eventId = json['eventId'] ?? 0;
    eventName = json['eventName'] ?? '';
    eventDate = json['eventDate'] ?? '';
    startTime = json['startTime'] ?? '';
    endTime = json['endTime'] ?? '';
    location = json['location'] ?? '';
    eventType = json['eventType'] ?? '';
    status = json['status'] ?? '';
    clubId = json['clubId'] ?? 0;
    activityId = json['activityId'];       // keep null as-is
    activityName = json['activityName'];   // keep null as-is
    createdByUserId = json['createdByUserId'] ?? 0;
    createdByUsername = json['createdByUsername'] ?? '';
    // Parse coaches array from API
    coaches = (json['coaches'] as List<dynamic>? ?? [])
        .map((c) => EventCoach.fromJson(c as Map<String, dynamic>))
        .toList();
    createdAt = json['createdAt'] ?? '';
  }

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'eventName': eventName,
      'eventDate': eventDate,
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
      'createdAt': createdAt,
    };
  }
}