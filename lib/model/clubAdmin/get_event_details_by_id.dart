import 'dart:convert';

GetEventById getEventByIdFromJson(String data) =>
    GetEventById.fromJson(json.decode(data));

class GetEventById {
  GetEventById({
    required this.success,
    required this.message,
    required this.data,
    this.errorCode,
    required this.timestamp,
  });

  late final bool success;
  late final String message;
  late final EventData data;
  late final dynamic errorCode;
  late final String timestamp;

  GetEventById.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = EventData.fromJson(json['data']);
    errorCode = json['errorCode'];
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.toJson(),
      'errorCode': errorCode,
      'timestamp': timestamp,
    };
  }
}

class EventData {
  EventData({
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
  late final int createdByUserId;
  late final String createdByUsername;
  late final List<int> coachIds;
  late final String createdAt;

  EventData.fromJson(Map<String, dynamic> json) {
    eventId = json['eventId'] ?? 0;
    eventName = json['eventName'] ?? "";
    eventDate = json['eventDate'] ?? "";
    startTime = json['startTime'] ?? "";
    endTime = json['endTime'] ?? "";
    location = json['location'] ?? "";
    eventType = json['eventType'] ?? "";
    status = json['status'] ?? "";
    clubId = json['clubId'] ?? 0;
    createdByUserId = json['createdByUserId'] ?? 0;
    createdByUsername = json['createdByUsername'] ?? "";
    coachIds = List.castFrom<dynamic, int>(json['coachIds']);
    createdAt = json['createdAt'] ?? "";
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
      'createdByUserId': createdByUserId,
      'createdByUsername': createdByUsername,
      'coachIds': coachIds,
      'createdAt': createdAt,
    };
  }
}