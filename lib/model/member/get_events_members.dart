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

class CoachData {
  final int coachId;
  final String coachName;

  CoachData({required this.coachId, required this.coachName});

  factory CoachData.fromJson(Map<String, dynamic> json) => CoachData(
    coachId: json['coachId'] ?? 0,
    coachName: json['coachName'] ?? '',
  );
}

class EventLocation {
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? mapLink;
  final String? placeName;

  EventLocation({
    this.latitude,
    this.longitude,
    this.address,
    this.mapLink,
    this.placeName,
  });

  factory EventLocation.fromJson(Map<String, dynamic> json) => EventLocation(
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
    address: json['address'],
    mapLink: json['mapLink'],
    placeName: json['placeName'],
  );
}

class MemberEventData {
  final int eventId;
  final String eventName;
  final String teamName;
  final String eventDate;
  final String status;
  final List<CoachData> assignedCoaches;
  final EventLocation? location;

  MemberEventData({
    required this.eventId,
    required this.eventName,
    required this.teamName,
    required this.eventDate,
    required this.status,
    required this.assignedCoaches,
    this.location,
  });

  factory MemberEventData.fromJson(Map<String, dynamic> json) => MemberEventData(
    eventId: json['eventId'] ?? 0,
    eventName: json['eventName'] ?? '',
    teamName: json['teamName'] ?? '',
    eventDate: json['eventDate'] ?? '',
    status: json['status'] ?? '',
    assignedCoaches: json['assignedCoaches'] == null
        ? []
        : List<CoachData>.from(
        (json['assignedCoaches'] as List).map((x) => CoachData.fromJson(x))),
    location: json['location'] != null
        ? EventLocation.fromJson(json['location'])
        : null,
  );
}