import 'dart:convert';

GetCoaches GetCoachesFromJson(String data) =>
    GetCoaches.fromJson(json.decode(data));

class GetCoaches {
  GetCoaches({
    required this.success,
    required this.message,
    required this.data,
    this.errorCode,
    required this.timestamp,
  });
  late final bool success;
  late final String message;
  late final List<CoachData> data;
  late final Null errorCode;
  late final String timestamp;

  GetCoaches.fromJson(Map<String, dynamic> json){
    success = json['success']??false;
    message = json['message']??"";
    data = List.from(json['data']).map((e)=>CoachData.fromJson(e)).toList();
    errorCode = null;
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

class CoachData {
  CoachData({
    required this.coachId,
    required this.userId,
    required this.username,
    required this.specialization,
    required this.experienceYears,
    required this.certification,
    required this.bio,
    required this.status,
  });
  late final int coachId;
  late final int userId;
  late final String username;
  late final String specialization;
  late final int experienceYears;
  late final String certification;
  late final String bio;
  late final String status;

  CoachData.fromJson(Map<String, dynamic> json){
    coachId = json['coachId']??0;
    userId = json['userId']??0;
    username = json['username']??"";
    specialization = json['specialization']??"";
    experienceYears = json['experienceYears']??0;
    certification = json['certification']??"";
    bio = json['bio']??"";
    status = json['status']??"";
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['coachId'] = coachId;
    _data['userId'] = userId;
    _data['username'] = username;
    _data['specialization'] = specialization;
    _data['experienceYears'] = experienceYears;
    _data['certification'] = certification;
    _data['bio'] = bio;
    _data['status'] = status;
    return _data;
  }
}