import 'dart:convert';

GetMembers GetMembersFromJson(String data) =>
    GetMembers.fromJson(json.decode(data));


class GetMembers {
  GetMembers({
    required this.success,
    required this.message,
    required this.data,
    required this.errorCode,
    required this.timestamp,
  });
  late final bool success;
  late final String message;
  late final List<Data> data;
  late final String errorCode;
  late final String timestamp;

  GetMembers.fromJson(Map<String, dynamic> json){
    success = json['success']??false;
    message = json['message']??"";
    data = List.from(json['data']).map((e)=>Data.fromJson(e)).toList();
    errorCode = json['errorCode']??"";
    timestamp = json['timestamp']??"";
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
    required this.memberId,
    required this.userId,
    this.dob,
    required this.username,
    required this.email,
    required this.gender,
    required this.medicalNotes,
    required this.createdAt,
  });
  late final int memberId;
  late final int userId;
  late final String? dob;
  late final String username;
  late final String email;
  late final String gender;
  late final String medicalNotes;
  late final String createdAt;

  Data.fromJson(Map<String, dynamic> json){
    memberId = json['memberId']??0;
    userId = json['userId']??0;
    dob = json["dob"];
    username = json['username']??"";
    email = json['email']??"";
    gender = json['gender']??"";
    medicalNotes = json['medicalNotes']??"";
    createdAt = json['createdAt']??"";
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['memberId'] = memberId;
    _data['userId'] = userId;
    _data['dob'] = dob;
    _data['username'] = username;
    _data['email'] = email;
    _data['gender'] = gender;
    _data['medicalNotes'] = medicalNotes;
    _data['createdAt'] = createdAt;
    return _data;
  }
}