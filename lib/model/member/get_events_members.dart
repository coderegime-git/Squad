// lib/model/member/get_member_events.dart
import 'dart:convert';

GetMemberEvents getMemberEventsFromJson(String str) =>
    GetMemberEvents.fromJson(json.decode(str));

class GetMemberEvents {
  final bool success;
  final String message;
  final List<MemberEventData> data;

  GetMemberEvents({
    required this.success,
    required this.message,
    required this.data,
  });

  factory GetMemberEvents.fromJson(Map<String, dynamic> json) =>
      GetMemberEvents(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
        data: json['data'] == null
            ? []
            : List<MemberEventData>.from(
            (json['data'] as List).map((x) => MemberEventData.fromJson(x))),
      );
}

class MemberEventData {
  final int eventId;
  final String eventName;
  final String teamName;
  final String eventDate;
  final String status;

  MemberEventData({
    required this.eventId,
    required this.eventName,
    required this.teamName,
    required this.eventDate,
    required this.status,
  });

  factory MemberEventData.fromJson(Map<String, dynamic> json) =>
      MemberEventData(
        eventId: json['eventId'] ?? 0,
        eventName: json['eventName'] ?? '',
        teamName: json['teamName'] ?? '',
        eventDate: json['eventDate'] ?? '',
        status: json['status'] ?? '',
      );
}