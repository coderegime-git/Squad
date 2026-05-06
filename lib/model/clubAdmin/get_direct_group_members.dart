
import 'dart:convert';

GetDirectGroupMembers GetDirectGroupMembersFromJson(String data) =>
    GetDirectGroupMembers.fromJson(json.decode(data));
class GetDirectGroupMembers {
  GetDirectGroupMembers({
    required this.success,
    required this.message,
    required this.data,
    this.errorCode,
    required this.timestamp,
  });
  late final bool success;
  late final String message;
  late final List<GetDirectGroupMembersData> data;
  late final Null errorCode;
  late final String timestamp;

  GetDirectGroupMembers.fromJson(Map<String, dynamic> json){
    success = json['success'];
    message = json['message'];
    data = List.from(json['data']).map((e)=>GetDirectGroupMembersData.fromJson(e)).toList();
    errorCode = null;
    timestamp = json['timestamp'];
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

class GetDirectGroupMembersData {
  GetDirectGroupMembersData({
    required this.memberId,
    required this.name,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    required this.directMember,
    this.subGroupId,
    this.subGroupName,
  });
  late final int memberId;
  late final String name;
  late final String email;
  late final String phone;
  late final String dateOfBirth;
  late final bool directMember;
  late final Null subGroupId;
  late final Null subGroupName;

  GetDirectGroupMembersData.fromJson(Map<String, dynamic> json){
    memberId = json['memberId'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    dateOfBirth = json['dateOfBirth'];
    directMember = json['directMember'];
    subGroupId = null;
    subGroupName = null;
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['memberId'] = memberId;
    _data['name'] = name;
    _data['email'] = email;
    _data['phone'] = phone;
    _data['dateOfBirth'] = dateOfBirth;
    _data['directMember'] = directMember;
    _data['subGroupId'] = subGroupId;
    _data['subGroupName'] = subGroupName;
    return _data;
  }
}