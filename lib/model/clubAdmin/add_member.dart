import 'dart:convert';

// GetMenuAccess GetMenuAccessFromJson(String data) =>
//     GetMenuAccess.fromJson(json.decode(data));

AddMember AddMembersFromJson(String data) =>
    AddMember.fromJson(json.decode(data));

class AddMember {
  AddMember({
    required this.success,
    required this.message,
    required this.data,
    required this.errorCode,
    required this.timestamp,
  });
  late final bool success;
  late final String message;
  late final Data data;
  late final String errorCode;
  late final String timestamp;

  AddMember.fromJson(Map<String, dynamic> json){
    success = json['success']??false;
    message = json['message']??"";
    data = Data.fromJson(json['data']);
    errorCode = json['errorCode']??"";
    timestamp = json['timestamp']??"";
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
    required this.memberId,
    required this.userId,
    required this.dob,
    required this.username,
    required this.email,
    required this.gender,
    required this.medicalNotes,
    this.createdAt,
  });
  late final int memberId;
  late final int userId;
  late final String dob;
  late final String username;
  late final String email;
  late final String gender;
  late final String medicalNotes;
  late final Null createdAt;

  Data.fromJson(Map<String, dynamic> json){
    memberId = json['memberId']??0;
    userId = json['userId']??0;
    dob = json['dob']??"";
    username = json['username']??"";
    email = json['email']??"";
    gender = json['gender']??"";
    medicalNotes = json['medicalNotes']??"";
    createdAt = null;
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