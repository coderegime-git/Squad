GetClubsData getClubsDataFromJson(Map<String, dynamic> json) =>
    GetClubsData.fromJson(json);

class GetClubsData {
  GetClubsData({
    required this.success,
    required this.message,
    required this.data,
    this.errorCode,
    required this.timestamp,
  });
  late final bool success;
  late final String message;
  late final List<GetClubsForRoles> data;
  late final Null errorCode;
  late final String timestamp;

  GetClubsData.fromJson(Map<String, dynamic> json){
    success = json['success']??"";
    message = json['message']??"";
    data = List.from(json['data']).map((e)=>GetClubsForRoles.fromJson(e)).toList();
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

class GetClubsForRoles {
  GetClubsForRoles({
    required this.clubId,
    required this.clubName,
    required this.description,
    this.createdAt,
  });
  late final int clubId;
  late final String clubName;
  late final String description;
  late final Null createdAt;

  GetClubsForRoles.fromJson(Map<String, dynamic> json){
    clubId = json['clubId']??0;
    clubName = json['clubName']??"";
    description = json['description']??"";
    createdAt = null;
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['clubId'] = clubId;
    _data['clubName'] = clubName;
    _data['description'] = description;
    _data['createdAt'] = createdAt;
    return _data;
  }
}