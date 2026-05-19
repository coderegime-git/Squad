// lib/model/coach/assigned_groups.dart

class AssignedGroupsData {
  final List<AssignedGroup> groups;
  final List<AssignedSubGroup> subGroups;

  AssignedGroupsData({required this.groups, required this.subGroups});

  factory AssignedGroupsData.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return AssignedGroupsData(
      groups: (data['groups'] as List? ?? [])
          .map((e) => AssignedGroup.fromJson(e))
          .toList(),
      subGroups: (data['subGroups'] as List? ?? [])
          .map((e) => AssignedSubGroup.fromJson(e))
          .toList(),
    );
  }
}

class AssignedGroup {
  final int groupId;
  final String groupName;

  AssignedGroup({required this.groupId, required this.groupName});

  factory AssignedGroup.fromJson(Map<String, dynamic> json) {
    return AssignedGroup(
      groupId: json['groupId'] ?? 0,
      groupName: json['groupName'] ?? '',
    );
  }
}

class AssignedSubGroup {
  final int subGroupId;
  final String subGroupName;

  AssignedSubGroup({required this.subGroupId, required this.subGroupName});

  factory AssignedSubGroup.fromJson(Map<String, dynamic> json) {
    return AssignedSubGroup(
      subGroupId: json['subGroupId'] ?? 0,
      subGroupName: json['subGroupName'] ?? '',
    );
  }
}