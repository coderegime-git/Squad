import 'dart:convert';

GetEventDetails GetEventDetailsFromJson(String data) =>
    GetEventDetails.fromJson(json.decode(data));


class GetEventDetails {
  GetEventDetails({
    required this.success,
    required this.message,
    required this.data,
    this.errorCode,
    required this.timestamp,
  });
  late final bool success;
  late final String message;
  late final List<Data> data;
  late final Null errorCode;
  late final String timestamp;

  GetEventDetails.fromJson(Map<String, dynamic> json){
    success = json['success'];
    message = json['message'];
    data = List.from(json['data']).map((e)=>Data.fromJson(e)).toList();
    errorCode = null;
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['success'] = success;
    _data['message'] = message;
    _data['data'] = data.map((e)=>e.toJson()).toList();
    _data['errorCode'] = errorCode;
    _data['timestamp'] = timestamp;
    return _data;
  }
}

class Data {
  Data({
    required this.eventId,
    required this.eventName,
    required this.eventDate,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.eventType,
    required this.status,
    required this.clubId,
    required this.createdByUserId,
    required this.createdByUsername,
    required this.coachIds,
    required this.createdAt,
  });
  late final int eventId;
  late final String eventName;
  late final String eventDate;
  late final String startTime;
  late final String endTime;
  late final String location;
  late final String eventType;
  late final String status;
  late final int clubId;
  late final int createdByUserId;
  late final String createdByUsername;
  late final List<int> coachIds;
  late final String createdAt;

  Data.fromJson(Map<String, dynamic> json){
    eventId = json['eventId']??0;
    eventName = json['eventName']??"";
    eventDate = json['eventDate']??"";
    startTime = json['startTime']??"";
    endTime = json['endTime']??"";
    location = json['location']??"";
    eventType = json['eventType']??"";
    status = json['status']??"";
    clubId = json['clubId']??0;
    createdByUserId = json['createdByUserId']??0;
    createdByUsername = json['createdByUsername']??"";
    coachIds = List.castFrom<dynamic, int>(json['coachIds']);
    createdAt = json['createdAt']??"";
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['eventId'] = eventId;
    _data['eventName'] = eventName;
    _data['eventDate'] = eventDate;
    _data['startTime'] = startTime;
    _data['endTime'] = endTime;
    _data['location'] = location;
    _data['eventType'] = eventType;
    _data['status'] = status;
    _data['clubId'] = clubId;
    _data['createdByUserId'] = createdByUserId;
    _data['createdByUsername'] = createdByUsername;
    _data['coachIds'] = coachIds;
    _data['createdAt'] = createdAt;
    return _data;
  }
}