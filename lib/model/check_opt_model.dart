class CheckOTPModel {
  bool? success;
  Data? data;
  String? msg;

  CheckOTPModel({this.success, this.data, this.msg});

  CheckOTPModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['msg'] = msg;
    return data;
  }
}

class Data {
  int? id;
  String? name;
  String? image;
  String? emailId;
  Null emailVerifiedAt;
  String? phone;
  int? isVerified;
  int? status;
  int? otp;
  Null favourite;
  String? createdAt;
  String? updatedAt;
  String? token;

  Data({this.id, this.name, this.image, this.emailId, this.emailVerifiedAt, this.phone, this.isVerified, this.status, this.otp, this.favourite, this.createdAt, this.updatedAt, this.token});

  Data.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id'].toString());
    name = json['name'];
    image = json['image'];
    emailId = json['email_id'];
    emailVerifiedAt = json['email_verified_at'];
    phone = json['phone'];
    isVerified = int.parse(json['is_verified'].toString());
    status = int.parse(json['status'].toString());
    otp = int.parse(json['otp'].toString());
    favourite = json['faviroute'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image'] = image;
    data['email_id'] = emailId;
    data['email_verified_at'] = emailVerifiedAt;
    data['phone'] = phone;
    data['is_verified'] = isVerified;
    data['status'] = status;
    data['otp'] = otp;
    data['faviroute'] = favourite;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['token'] = token;
    return data;
  }
}
