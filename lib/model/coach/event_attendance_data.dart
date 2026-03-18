EventAttendanceData eventAttendanceDataFromJson(Map<String, dynamic> json) =>
    EventAttendanceData.fromJson(json);

class EventAttendanceData {
  bool? success;
  String? message;
  List<Data>? data;
  Null? errorCode;
  String? timestamp;

  EventAttendanceData({
    this.success,
    this.message,
    this.data,
    this.errorCode,
    this.timestamp,
  });

  EventAttendanceData.fromJson(Map<String, dynamic> json) {
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
  String? memberName;
  String? status;
  String? markedAt;
  String? markedByCoach;

  Data({
    this.memberId,
    this.memberName,
    this.status,
    this.markedAt,
    this.markedByCoach,
  });

  Data.fromJson(Map<String, dynamic> json) {
    memberId = json['memberId'];
    memberName = json['memberName'];
    status = json['status'];
    markedAt = json['markedAt'];
    markedByCoach = json['markedByCoach'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['memberId'] = this.memberId;
    data['memberName'] = this.memberName;
    data['status'] = this.status;
    data['markedAt'] = this.markedAt;
    data['markedByCoach'] = this.markedByCoach;
    return data;
  }
}
