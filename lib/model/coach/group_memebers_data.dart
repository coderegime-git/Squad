GroupMembersData groupMembersDataFromJson(Map<String, dynamic> json) =>
    GroupMembersData.fromJson(json);

class GroupMembersData {
  bool? success;
  String? message;
  List<Data>? data;
  String? errorCode;
  String? timestamp;

  GroupMembersData({
    this.success,
    this.message,
    this.data,
    this.errorCode,
    this.timestamp,
  });

  GroupMembersData.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
    errorCode = json['errorCode'];
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['errorCode'] = this.errorCode;
    data['timestamp'] = this.timestamp;
    return data;
  }
}

class Data {
  int? memberId;
  String? username;
  String? email;
  String? mobile;
  String? dob;
  String? gender;
  String? medicalNotes;
  String? createdAt;
  int? groupId;
  String? groupName;
  int? subGroupId;
  String? subGroupName;
  int? teamId;
  String? teamName;

  Data({
    this.memberId,
    this.username,
    this.email,
    this.mobile,
    this.dob,
    this.gender,
    this.medicalNotes,
    this.createdAt,
    this.groupId,
    this.groupName,
    this.subGroupId,
    this.subGroupName,
    this.teamId,
    this.teamName,
  });

  Data.fromJson(Map<String, dynamic> json) {
    memberId = json['memberId'];
    username = json['username'];
    email = json['email'];
    mobile = json['mobile'];
    dob = json['dob'];
    gender = json['gender'];
    medicalNotes = json['medicalNotes'];
    createdAt = json['createdAt'];
    groupId = json['groupId'];
    groupName = json['groupName'];
    subGroupId = json['subGroupId'];
    subGroupName = json['subGroupName'];
    teamId = json['teamId'];
    teamName = json['teamName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['memberId'] = this.memberId;
    data['username'] = this.username;
    data['email'] = this.email;
    data['mobile'] = this.mobile;
    data['dob'] = this.dob;
    data['gender'] = this.gender;
    data['medicalNotes'] = this.medicalNotes;
    data['createdAt'] = this.createdAt;
    data['groupId'] = this.groupId;
    data['groupName'] = this.groupName;
    data['subGroupId'] = this.subGroupId;
    data['subGroupName'] = this.subGroupName;
    data['teamId'] = this.teamId;
    data['teamName'] = this.teamName;
    return data;
  }
}
