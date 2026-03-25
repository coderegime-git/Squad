class PerformanceNotesData {
  bool? success;
  String? message;
  List<Data>? data;
  Null? errorCode;
  String? timestamp;

  PerformanceNotesData({
    this.success,
    this.message,
    this.data,
    this.errorCode,
    this.timestamp,
  });

  PerformanceNotesData.fromJson(Map<String, dynamic> json) {
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
  int? noteId;
  int? memberId;
  String? memberName;
  int? eventId;
  String? eventName;
  String? note;
  int? rating;
  int? coachId;
  String? coachName;
  String? createdAt;

  Data({
    this.noteId,
    this.memberId,
    this.memberName,
    this.eventId,
    this.eventName,
    this.note,
    this.rating,
    this.coachId,
    this.coachName,
    this.createdAt,
  });

  Data.fromJson(Map<String, dynamic> json) {
    noteId = json['noteId'];
    memberId = json['memberId'];
    memberName = json['memberName'];
    eventId = json['eventId'];
    eventName = json['eventName'];
    note = json['note'];
    rating = json['rating'];
    coachId = json['coachId'];
    coachName = json['coachName'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['noteId'] = this.noteId;
    data['memberId'] = this.memberId;
    data['memberName'] = this.memberName;
    data['eventId'] = this.eventId;
    data['eventName'] = this.eventName;
    data['note'] = this.note;
    data['rating'] = this.rating;
    data['coachId'] = this.coachId;
    data['coachName'] = this.coachName;
    data['createdAt'] = this.createdAt;
    return data;
  }
}
