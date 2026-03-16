import 'dart:convert';

GetGroups getGroupsFromJson(String data) =>
    GetGroups.fromJson(json.decode(data));

class GetGroups {
  GetGroups({
    required this.success,
    required this.message,
    required this.data,
    this.errorCode,
    required this.timestamp,
  });
  late final bool success;
  late final String message;
  late final List<GroupData> data;
  late final dynamic errorCode;
  late final String timestamp;

  GetGroups.fromJson(Map<String, dynamic> json) {
    success = json['success'] ?? false;
    message = json['message'] ?? '';
    data = List.from(json['data'] ?? [])
        .map((e) => GroupData.fromJson(e))
        .toList();
    errorCode = json['errorCode'];
    timestamp = json['timestamp'] ?? '';
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

class GroupData {
  GroupData({
    required this.groupId,
    required this.eventId,
    required this.name,
    required this.description,
    required this.status,
    required this.createdTs,
    required this.updatedTs,
  });

  late final int groupId;
  late final int eventId;
  late final String name;
  late final String description;
  late final String status;
  late final String createdTs;
  late final String updatedTs;

  GroupData.fromJson(Map<String, dynamic> json) {
    groupId = json['groupId'] ?? 0;
    eventId = json['eventId'] ?? 0;
    name = json['name'] ?? '';
    description = json['description'] ?? '';
    status = json['status'] ?? '';
    createdTs = json['createdTs'] ?? '';
    updatedTs = json['updatedTs'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['groupId'] = groupId;
    _data['eventId'] = eventId;
    _data['name'] = name;
    _data['description'] = description;
    _data['status'] = status;
    _data['createdTs'] = createdTs;
    _data['updatedTs'] = updatedTs;
    return _data;
  }
}