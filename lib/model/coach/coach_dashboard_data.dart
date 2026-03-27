class CoachDashboardData {
  final List<DashboardSession> todaySessions;
  final DashboardStats stats;
  final DashboardEvents events;
  final DashboardAttendance attendance;

  CoachDashboardData({
    required this.todaySessions,
    required this.stats,
    required this.events,
    required this.attendance,
  });

  factory CoachDashboardData.fromJson(Map<String, dynamic> json) {
    print("CoachDashboardData.fromJson raw: $json"); // ← debug log

    return CoachDashboardData(
      todaySessions: (json['todaySessions'] as List?)
          ?.map((s) => DashboardSession.fromJson(Map<String, dynamic>.from(s)))
          .toList() ??
          [],
      stats: json['stats'] != null
          ? DashboardStats.fromJson(Map<String, dynamic>.from(json['stats']))
          : DashboardStats(totalMembers: 0, totalGroups: 0),
      events: json['events'] != null
          ? DashboardEvents.fromJson(Map<String, dynamic>.from(json['events']))
          : DashboardEvents(upcoming: 0),
      attendance: json['attendance'] != null
          ? DashboardAttendance.fromJson(Map<String, dynamic>.from(json['attendance']))
          : DashboardAttendance(pending: 0, completedToday: 0),
    );
  }

  factory CoachDashboardData.empty() => CoachDashboardData(
    todaySessions: [],
    stats:      DashboardStats(totalMembers: 0, totalGroups: 0),
    events:     DashboardEvents(upcoming: 0),
    attendance: DashboardAttendance(pending: 0, completedToday: 0),
  );
}

class DashboardSession {
  final int? eventId;
  final String groupName;
  final SessionTime? time;
  final String location;
  final bool attendanceMarked;

  DashboardSession({
    this.eventId,
    required this.groupName,
    this.time,
    required this.location,
    required this.attendanceMarked,
  });

  factory DashboardSession.fromJson(Map<String, dynamic> json) {
    return DashboardSession(
      eventId:         json['eventId'] as int?,
      groupName:       json['groupName']?.toString() ?? '',
      time: json['time'] != null
          ? SessionTime.fromJson(Map<String, dynamic>.from(json['time']))
          : null,
      location:        json['location']?.toString() ?? '',
      attendanceMarked: json['attendanceMarked'] as bool? ?? false,
    );
  }

  String get formattedTime {
    if (time == null) return '';
    final hour = time!.hour;
    final minute = time!.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : hour == 0 ? 12 : hour;
    return '$displayHour:$minute $period';
  }
}

class SessionTime {
  final int hour;
  final int minute;
  final int second;
  final int nano;

  SessionTime({
    required this.hour,
    required this.minute,
    required this.second,
    required this.nano,
  });

  factory SessionTime.fromJson(Map<String, dynamic> json) {
    return SessionTime(
      hour:   (json['hour']   as num?)?.toInt() ?? 0,
      minute: (json['minute'] as num?)?.toInt() ?? 0,
      second: (json['second'] as num?)?.toInt() ?? 0,
      nano:   (json['nano']   as num?)?.toInt() ?? 0,
    );
  }
}

class DashboardStats {
  final int totalMembers;
  final int totalGroups;

  DashboardStats({required this.totalMembers, required this.totalGroups});

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    print("DashboardStats.fromJson: $json"); // ← debug log
    return DashboardStats(
      totalMembers: (json['totalMembers'] as num?)?.toInt() ?? 0,
      totalGroups:  (json['totalGroups']  as num?)?.toInt() ?? 0,
    );
  }
}

class DashboardEvents {
  final int upcoming;

  DashboardEvents({required this.upcoming});

  factory DashboardEvents.fromJson(Map<String, dynamic> json) {
    print("DashboardEvents.fromJson: $json"); // ← debug log
    return DashboardEvents(
      upcoming: (json['upcoming'] as num?)?.toInt() ?? 0,
    );
  }
}

class DashboardAttendance {
  final int pending;
  final int completedToday;

  DashboardAttendance({required this.pending, required this.completedToday});

  factory DashboardAttendance.fromJson(Map<String, dynamic> json) {
    print("DashboardAttendance.fromJson: $json"); // ← debug log
    return DashboardAttendance(
      pending:        (json['pending']        as num?)?.toInt() ?? 0,
      completedToday: (json['completedToday'] as num?)?.toInt() ?? 0,
    );
  }

  factory DashboardAttendance.empty() =>
      DashboardAttendance(pending: 0, completedToday: 0);
}