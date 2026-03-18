ActivityData activityDataFromJson(Map<String, dynamic> json) =>
    ActivityData.fromJson(json);

class ActivityData {
  bool? success;
  String? message;
  ActivityListData? data;
  Null? errorCode;
  String? timestamp;

  ActivityData({
    this.success,
    this.message,
    this.data,
    this.errorCode,
    this.timestamp,
  });

  ActivityData.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null
        ? new ActivityListData.fromJson(json['data'])
        : null;
    errorCode = json['errorCode'];
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['errorCode'] = this.errorCode;
    data['timestamp'] = this.timestamp;
    return data;
  }
}

class ActivityListData {
  int? activityId;
  int? clubId;
  String? name;
  String? description;
  String? activityType;
  String? startDateTime;
  String? endDateTime;
  int? createdBy;
  String? createdRole;
  String? status;
  String? createdAt;
  String? updatedAt;

  ActivityListData({
    this.activityId,
    this.clubId,
    this.name,
    this.description,
    this.activityType,
    this.startDateTime,
    this.endDateTime,
    this.createdBy,
    this.createdRole,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  ActivityListData.fromJson(Map<String, dynamic> json) {
    activityId = json['activityId'];
    clubId = json['clubId'];
    name = json['name'];
    description = json['description'];
    activityType = json['activityType'];
    startDateTime = json['startDateTime'];
    endDateTime = json['endDateTime'];
    createdBy = json['createdBy'];
    createdRole = json['createdRole'];
    status = json['status'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['activityId'] = this.activityId;
    data['clubId'] = this.clubId;
    data['name'] = this.name;
    data['description'] = this.description;
    data['activityType'] = this.activityType;
    data['startDateTime'] = this.startDateTime;
    data['endDateTime'] = this.endDateTime;
    data['createdBy'] = this.createdBy;
    data['createdRole'] = this.createdRole;
    data['status'] = this.status;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}
