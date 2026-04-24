import 'dart:convert';

import 'get_events_members.dart';

GetGuardiansByMember getGuardianByMemberFromJson(String str) =>
    GetGuardiansByMember.fromJson(json.decode(str));

class GetGuardiansByMember {
  GetGuardiansByMember({
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

  GetGuardiansByMember.fromJson(Map<String, dynamic> json){
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
    required this.guardianId,
    required this.userId,
    required this.username,
    required this.relation,
    required this.emergencyContact,
  });
  late final int guardianId;
  late final int userId;
  late final String username;
  late final String relation;
  late final String emergencyContact;

  Data.fromJson(Map<String, dynamic> json){
    guardianId = json['guardianId'];
    userId = json['userId'];
    username = json['username'];
    relation = json['relation'];
    emergencyContact = json['emergencyContact'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['guardianId'] = guardianId;
    _data['userId'] = userId;
    _data['username'] = username;
    _data['relation'] = relation;
    _data['emergencyContact'] = emergencyContact;
    return _data;
  }
}