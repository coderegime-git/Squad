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

class GuardianCoachData {
  final int coachId;
  final String coachName;

  GuardianCoachData({required this.coachId, required this.coachName});

  factory GuardianCoachData.fromJson(Map<String, dynamic> json) => GuardianCoachData(
    coachId: json['coachId'] ?? 0,
    coachName: json['coachName'] ?? '',
  );
}

class GuardianEventLocation {
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? mapLink;
  final String? placeName;

  GuardianEventLocation({
    this.latitude,
    this.longitude,
    this.address,
    this.mapLink,
    this.placeName,
  });

  factory GuardianEventLocation.fromJson(Map<String, dynamic> json) => GuardianEventLocation(
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
    address: json['address'],
    mapLink: json['mapLink'],
    placeName: json['placeName'],
  );
}

class GuardianEventData {
  final int eventId;
  final String eventName;
  final String teamName;
  final String eventDate;
  final String status;
  final List<GuardianCoachData> assignedCoaches;
  final GuardianEventLocation? location;

  GuardianEventData({
    required this.eventId,
    required this.eventName,
    required this.teamName,
    required this.eventDate,
    required this.status,
    required this.assignedCoaches,
    this.location,
  });

  factory GuardianEventData.fromJson(Map<String, dynamic> json) => GuardianEventData(
    eventId: json['eventId'] ?? 0,
    eventName: json['eventName'] ?? '',
    teamName: json['teamName'] ?? '',
    eventDate: json['eventDate'] ?? '',
    status: json['status'] ?? '',
    assignedCoaches: json['assignedCoaches'] == null
        ? []
        : List<GuardianCoachData>.from(
        (json['assignedCoaches'] as List)
            .map((x) => GuardianCoachData.fromJson(x))),
    location: json['location'] != null
        ? GuardianEventLocation.fromJson(json['location'])
        : null,
  );
}