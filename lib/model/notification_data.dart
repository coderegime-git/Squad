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
  int? memberId;  // ✅ changed Null? → int?
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
    notificationId = json['notificationId'] ?? 0;
    clubId = json['clubId'] ?? 0;
    userId = json['userId'] ?? 0;
    role = json['role'] ?? "";
    notificationType = json['notificationType'] ?? "";
    title = json['title'] ?? "";
    message = json['message'] ?? "";
    eventId = json['eventId'] as int?;        // ✅ can be null
    memberId = json['memberId'] as int?;      // ✅ can be null or int
    isRead = json['isRead'] ?? false;
    createdAt = json['createdAt'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['notificationId'] = notificationId;
    data['clubId'] = clubId;
    data['userId'] = userId;
    data['role'] = role;
    data['notificationType'] = notificationType;
    data['title'] = title;
    data['message'] = message;
    data['eventId'] = eventId;
    data['memberId'] = memberId;
    data['isRead'] = isRead;
    data['createdAt'] = createdAt;
    return data;
  }
}