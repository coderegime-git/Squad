MemberProfileData profileDataFromJson(Map<String,dynamic> json)=>MemberProfileData.fromJson(json);


class MemberProfileData {

  bool? success;
  String? message;
  Data? data;
  String? errorCode;
  String? timestamp;

  MemberProfileData(
      {this.success, this.message, this.data, this.errorCode, this.timestamp});

  MemberProfileData.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
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

class Data {
  User? user;
  Profile? profile;
  List<Null>? addresses;
  List<Memberships>? memberships;

  Data({this.user, this.profile, this.addresses, this.memberships});

  Data.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    profile =
    json['profile'] != null ? new Profile.fromJson(json['profile']) : null;
    if (json['addresses'] != null) {
      addresses = <Null>[];
      json['addresses'].forEach((v) {
       // addresses!.add(new Null.fromJson(v));
      });
    }
    if (json['memberships'] != null) {
      memberships = <Memberships>[];
      json['memberships'].forEach((v) {
        memberships!.add(new Memberships.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    if (this.profile != null) {
      data['profile'] = this.profile!.toJson();
    }
    if (this.addresses != null) {
      //data['addresses'] = this.addresses!.map((v) => v.toJson()).toList();
    }
    if (this.memberships != null) {
      data['memberships'] = this.memberships!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class User {
  int? id;
  String? username;
  String? mobile;
  String? email;

  User({this.id, this.username, this.mobile, this.email});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    mobile = json['mobile'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['username'] = this.username;
    data['mobile'] = this.mobile;
    data['email'] = this.email;
    return data;
  }
}

class Profile {
  String? firstName;
  String? lastName;
  String? dateOfBirth;
  String? gender;
  String? profileImageUrl;
  String? emergencyContactName;
  String? emergencyContactPhone;

  Profile(
      {this.firstName,
        this.lastName,
        this.dateOfBirth,
        this.gender,
        this.profileImageUrl,
        this.emergencyContactName,
        this.emergencyContactPhone});

  Profile.fromJson(Map<String, dynamic> json) {
    firstName = json['firstName'];
    lastName = json['lastName'];
    dateOfBirth = json['dateOfBirth'];
    gender = json['gender'];
    profileImageUrl = json['profileImageUrl'];
    emergencyContactName = json['emergencyContactName'];
    emergencyContactPhone = json['emergencyContactPhone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['firstName'] = this.firstName;
    data['lastName'] = this.lastName;
    data['dateOfBirth'] = this.dateOfBirth;
    data['gender'] = this.gender;
    data['profileImageUrl'] = this.profileImageUrl;
    data['emergencyContactName'] = this.emergencyContactName;
    data['emergencyContactPhone'] = this.emergencyContactPhone;
    return data;
  }
}

class Memberships {
  int? clubId;
  String? clubName;
  String? role;
  String? membershipStartDate;
  String? membershipEndDate;
  String? status;

  Memberships(
      {this.clubId,
        this.clubName,
        this.role,
        this.membershipStartDate,
        this.membershipEndDate,
        this.status});

  Memberships.fromJson(Map<String, dynamic> json) {
    clubId = json['clubId'];
    clubName = json['clubName'];
    role = json['role'];
    membershipStartDate = json['membershipStartDate'];
    membershipEndDate = json['membershipEndDate'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['clubId'] = this.clubId;
    data['clubName'] = this.clubName;
    data['role'] = this.role;
    data['membershipStartDate'] = this.membershipStartDate;
    data['membershipEndDate'] = this.membershipEndDate;
    data['status'] = this.status;
    return data;
  }
}