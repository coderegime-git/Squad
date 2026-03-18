// model/clubAdmin/get_sub_groups.dart
import 'dart:convert';

GetSubGroups getSubGroupsFromJson(String str) =>
    GetSubGroups.fromJson(json.decode(str));

class GetSubGroups {
  final bool success;
  final String message;
  final List<SubGroupData> data;

  GetSubGroups({
    required this.success,
    required this.message,
    required this.data,
  });

  factory GetSubGroups.fromJson(Map<String, dynamic> json) => GetSubGroups(
    success: json['success'] ?? false,
    message: json['message'] ?? '',
    data: json['data'] == null
        ? []
        : List<SubGroupData>.from(
        (json['data'] as List).map((x) => SubGroupData.fromJson(x))),
  );
}

class SubGroupData {
  final int subGroupId;
  final int groupId;
  final String name;
  final String description;
  final String status;
  final String? ageCategory;

  SubGroupData({
    required this.subGroupId,
    required this.groupId,
    required this.name,
    required this.description,
    required this.status,
    this.ageCategory,
  });

  factory SubGroupData.fromJson(Map<String, dynamic> json) => SubGroupData(
    subGroupId: json['subGroupId'] ?? json['id'] ?? 0,
    groupId: json['groupId'] ?? 0,
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    status: json['status'] ?? 'ACTIVE',
    ageCategory: json['ageCategory'],
  );
}