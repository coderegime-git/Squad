class NotificationData {
  bool? success;
  String? message;
  List<Data>? data;
  Null? errorCode;
  String? timestamp;

  NotificationData({
    this.success,
    this.message,
    this.data,
    this.errorCode,
    this.timestamp,
  });

  NotificationData.fromJson(Map<String, dynamic> json) {
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
  int? notificationId;
  int? clubId;
  int? userId;
  String? role;
  String? notificationType;
  String? title;
  String? message;
  int? eventId;
  Null? memberId;
  bool? isRead;
  String? createdAt;

  Data({
    this.notificationId,
    this.clubId,
    this.userId,
    this.role,
    this.notificationType,
    this.title,
    this.message,
    this.eventId,
    this.memberId,
    this.isRead,
    this.createdAt,
  });

  Data.fromJson(Map<String, dynamic> json) {
    notificationId = json['notificationId'];
    clubId = json['clubId'];
    userId = json['userId'];
    role = json['role'];
    notificationType = json['notificationType'];
    title = json['title'];
    message = json['message'];
    eventId = json['eventId'];
    memberId = json['memberId'];
    isRead = json['isRead'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['notificationId'] = this.notificationId;
    data['clubId'] = this.clubId;
    data['userId'] = this.userId;
    data['role'] = this.role;
    data['notificationType'] = this.notificationType;
    data['title'] = this.title;
    data['message'] = this.message;
    data['eventId'] = this.eventId;
    data['memberId'] = this.memberId;
    data['isRead'] = this.isRead;
    data['createdAt'] = this.createdAt;
    return data;
  }
}
