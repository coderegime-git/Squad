class GetMemberDashboard {
  final bool success;
  final String message;
  final MemberDashboardData? data;

  GetMemberDashboard({
    required this.success,
    required this.message,
    this.data,
  });

  factory GetMemberDashboard.fromJson(Map<String, dynamic> json) {
    return GetMemberDashboard(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? MemberDashboardData.fromJson(
          Map<String, dynamic>.from(json['data']))
          : null,
    );
  }

  factory GetMemberDashboard.empty() => GetMemberDashboard(
    success: false,
    message: '',
    data: null,
  );
}

class MemberDashboardData {
  final List<MemberClub> clubs;

  MemberDashboardData({required this.clubs});

  factory MemberDashboardData.fromJson(Map<String, dynamic> json) {
    final clubsList = json['clubs'] as List<dynamic>? ?? [];
    return MemberDashboardData(
      clubs: clubsList
          .map((c) => MemberClub.fromJson(Map<String, dynamic>.from(c)))
          .toList(),
    );
  }
}

class MemberClub {
  final String clubName;
  final List<MemberActivity> activities;
  final List<MemberEvent> events;
  final AttendanceStats attendanceStats;
  final MemberEvent? nextEvent;

  MemberClub({
    required this.clubName,
    required this.activities,
    required this.events,
    required this.attendanceStats,
    this.nextEvent,
  });

  factory MemberClub.fromJson(Map<String, dynamic> json) {
    final activitiesList = json['activities'] as List<dynamic>? ?? [];
    final eventsList = json['events'] as List<dynamic>? ?? [];

    return MemberClub(
      clubName: json['clubName'] ?? '',
      activities: activitiesList
          .map((a) => MemberActivity.fromJson(Map<String, dynamic>.from(a)))
          .toList(),
      events: eventsList
          .map((e) => MemberEvent.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      attendanceStats: json['attendanceStats'] != null
          ? AttendanceStats.fromJson(
          Map<String, dynamic>.from(json['attendanceStats']))
          : AttendanceStats(percentage: 0, totalSessions: 0),
      nextEvent: json['nextEvent'] != null
          ? MemberEvent.fromJson(Map<String, dynamic>.from(json['nextEvent']))
          : null,
    );
  }
}

class MemberActivity {
  final String activityName;

  MemberActivity({required this.activityName});

  factory MemberActivity.fromJson(Map<String, dynamic> json) {
    return MemberActivity(activityName: json['activityName'] ?? '');
  }
}

class MemberEvent {
  final int eventId;
  final String eventName;
  final String eventDate;
  final List<dynamic> groups;

  MemberEvent({
    required this.eventId,
    required this.eventName,
    required this.eventDate,
    required this.groups,
  });

  factory MemberEvent.fromJson(Map<String, dynamic> json) {
    return MemberEvent(
      eventId: json['eventId'] ?? 0,
      eventName: json['eventName'] ?? '',
      eventDate: json['eventDate'] ?? '',
      groups: json['groups'] as List<dynamic>? ?? [],
    );
  }
}

class AttendanceStats {
  final int percentage;
  final int totalSessions;

  AttendanceStats({required this.percentage, required this.totalSessions});

  factory AttendanceStats.fromJson(Map<String, dynamic> json) {
    return AttendanceStats(
      percentage: (json['percentage'] ?? 0).toInt(),
      totalSessions: (json['totalSessions'] ?? 0).toInt(),
    );
  }
}