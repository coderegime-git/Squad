// model/clubAdmin/get_teams.dart
import 'dart:convert';

GetTeams getTeamsFromJson(String str) => GetTeams.fromJson(json.decode(str));

class GetTeams {
  final bool success;
  final String message;
  final List<TeamData> data;

  GetTeams({
    required this.success,
    required this.message,
    required this.data,
  });

  factory GetTeams.fromJson(Map<String, dynamic> json) => GetTeams(
    success: json['success'] ?? false,
    message: json['message'] ?? '',
    data: json['data'] == null
        ? []
        : List<TeamData>.from(
        (json['data'] as List).map((x) => TeamData.fromJson(x))),
  );
}

class TeamData {
  final int teamId;
  final int subGroupId;
  final String name;
  final List<dynamic> coachIds;

  TeamData({
    required this.teamId,
    required this.subGroupId,
    required this.name,
    required this.coachIds,
  });

  factory TeamData.fromJson(Map<String, dynamic> json) => TeamData(
    teamId: json['teamId'] ?? json['id'] ?? 0,
    subGroupId: json['subGroupId'] ?? 0,
    name: json['name'] ?? '',
    coachIds: json['coachIds'] ?? [],
  );
}