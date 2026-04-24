
import 'dart:convert';

SubGroupMembers SubGroupMembersFromJson(String data) =>
    SubGroupMembers.fromJson(json.decode(data));
class SubGroupMembers {
  SubGroupMembers({
    required this.success,
    required this.message,
    required this.data,
    this.errorCode,
    required this.timestamp,
  });
  late final bool success;
  late final String message;
  late final List<SubMemData> data;
  late final Null errorCode;
  late final String timestamp;

  SubGroupMembers.fromJson(Map<String, dynamic> json){
    success = json['success'];
    message = json['message'];
    data = List.from(json['data']).map((e)=>SubMemData.fromJson(e)).toList();
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

class SubMemData {
  SubMemData({
    required this.memberId,
    required this.name,
    required this.email,
    required this.phone,
    this.dateOfBirth,
    required this.addedAt,
  });
  late final int memberId;
  late final String name;
  late final String email;
  late final String phone;
  late final String? dateOfBirth;
  late final String addedAt;

  SubMemData.fromJson(Map<String, dynamic> json){
    memberId = json['memberId'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    dateOfBirth = null;
    addedAt = json['addedAt'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['memberId'] = memberId;
    _data['name'] = name;
    _data['email'] = email;
    _data['phone'] = phone;
    _data['dateOfBirth'] = dateOfBirth;
    _data['addedAt'] = addedAt;
    return _data;
  }
}