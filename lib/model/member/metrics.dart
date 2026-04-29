import 'dart:convert';

GetMetrics getMemberMetricsFromJson(String str) =>
    GetMetrics.fromJson(json.decode(str));


class GetMetrics {
  GetMetrics({
    required this.success,
    required this.message,
    required this.data,
    this.errorCode,
    required this.timestamp,
  });
  late final bool success;
  late final String message;
  late final Data data;
  late final Null errorCode;
  late final String timestamp;

  GetMetrics.fromJson(Map<String, dynamic> json){
    success = json['success'];
    message = json['message'];
    data = Data.fromJson(json['data']);
    errorCode = null;
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['success'] = success;
    _data['message'] = message;
    _data['data'] = data.toJson();
    _data['errorCode'] = errorCode;
    _data['timestamp'] = timestamp;
    return _data;
  }
}

class Data {
  Data({
    required this.attendancePercentage,
    required this.currentStreak,
    required this.activities,
    required this.upcomingEvents,
    required this.attendanceHistory,
    required this.coachFeedback,
  });
  late final int attendancePercentage;
  late final int currentStreak;
  late final List<String> activities;
  late final List<UpcomingEvents> upcomingEvents;
  late final List<AttendanceHistory> attendanceHistory;
  late final List<CoachFeedback> coachFeedback;

  Data.fromJson(Map<String, dynamic> json){
    attendancePercentage = json['attendancePercentage'];
    currentStreak = json['currentStreak'];
    activities = List.castFrom<dynamic, String>(json['activities']);
    upcomingEvents = List.from(json['upcomingEvents']).map((e)=>UpcomingEvents.fromJson(e)).toList();
    attendanceHistory = List.from(json['attendanceHistory']).map((e)=>AttendanceHistory.fromJson(e)).toList();
    coachFeedback = List.from(json['coachFeedback']).map((e)=>CoachFeedback.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['attendancePercentage'] = attendancePercentage;
    _data['currentStreak'] = currentStreak;
    _data['activities'] = activities;
    _data['upcomingEvents'] = upcomingEvents.map((e)=>e.toJson()).toList();
    _data['attendanceHistory'] = attendanceHistory.map((e)=>e.toJson()).toList();
    _data['coachFeedback'] = coachFeedback.map((e)=>e.toJson()).toList();
    return _data;
  }
}

class UpcomingEvents {
  UpcomingEvents({
    required this.eventId,
    required this.eventName,
    required this.eventDate,
    required this.eventTime,
    required this.location,
    required this.eventType,
  });
  late final int eventId;
  late final String eventName;
  late final String eventDate;
  late final String eventTime;
  late final String location;
  late final String eventType;

  UpcomingEvents.fromJson(Map<String, dynamic> json){
    eventId = json['eventId']??0;
    eventName = json['eventName']??"";
    eventDate = json['eventDate']??"";
    eventTime = json['eventTime']??"";
    location = json['location']??"";
    eventType = json['eventType']??"";
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['eventId'] = eventId;
    _data['eventName'] = eventName;
    _data['eventDate'] = eventDate;
    _data['eventTime'] = eventTime;
    _data['location'] = location;
    _data['eventType'] = eventType;
    return _data;
  }
}

class AttendanceHistory {
  AttendanceHistory({
    required this.eventName,
    required this.eventDate,
    required this.status,
  });
  late final String eventName;
  late final String eventDate;
  late final String status;

  AttendanceHistory.fromJson(Map<String, dynamic> json){
    eventName = json['eventName']??"";
    eventDate = json['eventDate']??"";
    status = json['status']??"";
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['eventName'] = eventName;
    _data['eventDate'] = eventDate;
    _data['status'] = status;
    return _data;
  }
}

class CoachFeedback {
  CoachFeedback({
    required this.comment,
    required this.date,
    required this.coachName,
  });
  late final String comment;
  late final String date;
  late final String coachName;

  CoachFeedback.fromJson(Map<String, dynamic> json){
    comment = json['comment']??"";
    date = json['date']??"";
    coachName = json['coachName']??"";
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['comment'] = comment;
    _data['date'] = date;
    _data['coachName'] = coachName;
    return _data;
  }
}