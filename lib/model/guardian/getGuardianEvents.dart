// lib/model/guardian/get_guardian_events.dart
import 'dart:convert';

GetGuardianEvents getGuardianEventsFromJson(String str) =>
    GetGuardianEvents.fromJson(json.decode(str));

class GetGuardianEvents {
  final bool success;
  final String message;
  final List<GuardianEventData> data;

  GetGuardianEvents({
    required this.success,
    required this.message,
    required this.data,
  });

  factory GetGuardianEvents.fromJson(Map<String, dynamic> json) =>
      GetGuardianEvents(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
        data: json['data'] == null
            ? []
            : List<GuardianEventData>.from(
            (json['data'] as List).map((x) => GuardianEventData.fromJson(x))),
      );
}

class GuardianEventData {
  final int eventId;
  final String eventName;
  final String teamName;
  final String eventDate;
  final String status;

  GuardianEventData({
    required this.eventId,
    required this.eventName,
    required this.teamName,
    required this.eventDate,
    required this.status,
  });

  factory GuardianEventData.fromJson(Map<String, dynamic> json) =>
      GuardianEventData(
        eventId: json['eventId'] ?? 0,
        eventName: json['eventName'] ?? '',
        teamName: json['teamName'] ?? '',
        eventDate: json['eventDate'] ?? '',
        status: json['status'] ?? '',
      );
}