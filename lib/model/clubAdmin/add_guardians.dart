import 'dart:convert';

AddGuardian AddGuardianFromJson(String data) =>
    AddGuardian.fromJson(json.decode(data));

class AddGuardian {
  AddGuardian({
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

  AddGuardian.fromJson(Map<String, dynamic> json){
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
    guardianId = json['guardianId']??0;
    userId = json['userId']??0;
    username = json['username']??"";
    relation = json['relation']??"";
    emergencyContact = json['emergencyContact']??"";
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