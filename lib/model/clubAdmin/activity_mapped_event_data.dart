ActivityMappedEventData activityMappedEventDataFromJson(
  Map<String, dynamic> json,
) => ActivityMappedEventData.fromJson(json);

class ActivityMappedEventData {
  bool? success;
  String? message;
  List<Data>? data;
  Null? errorCode;
  String? timestamp;

  ActivityMappedEventData({
    this.success,
    this.message,
    this.data,
    this.errorCode,
    this.timestamp,
  });

  ActivityMappedEventData.fromJson(Map<String, dynamic> json) {
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
  int? eventId;
  String? eventName;
  String? eventDate;
  String? startTime;
  String? endTime;
  String? location;
  String? eventType;
  String? status;
  int? clubId;
  int? createdByUserId;
  String? createdByUsername;
  List<int>? coachIds;
  String? createdAt;

  Data({
    this.eventId,
    this.eventName,
    this.eventDate,
    this.startTime,
    this.endTime,
    this.location,
    this.eventType,
    this.status,
    this.clubId,
    this.createdByUserId,
    this.createdByUsername,
    this.coachIds,
    this.createdAt,
  });

  Data.fromJson(Map<String, dynamic> json) {
    eventId = json['eventId'];
    eventName = json['eventName'];
    eventDate = json['eventDate'];
    startTime = json['startTime'];
    endTime = json['endTime'];
    location = json['location'];
    eventType = json['eventType'];
    status = json['status'];
    clubId = json['clubId'];
    createdByUserId = json['createdByUserId'];
    createdByUsername = json['createdByUsername'];
    coachIds = json['coachIds'].cast<int>();
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['eventId'] = this.eventId;
    data['eventName'] = this.eventName;
    data['eventDate'] = this.eventDate;
    data['startTime'] = this.startTime;
    data['endTime'] = this.endTime;
    data['location'] = this.location;
    data['eventType'] = this.eventType;
    data['status'] = this.status;
    data['clubId'] = this.clubId;
    data['createdByUserId'] = this.createdByUserId;
    data['createdByUsername'] = this.createdByUsername;
    data['coachIds'] = this.coachIds;
    data['createdAt'] = this.createdAt;
    return data;
  }
}
