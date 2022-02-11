class SendOTPModel {
  bool? success;
  Data? data;
  String? msg;

  SendOTPModel({this.success, this.data, this.msg});

  SendOTPModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['msg'] = msg;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? id;
  String? name;
  String? image;
  String? emailId;
  String? emailVerifiedAt;
  String? deviceToken;
  String? phone;
  int? isVerified;
  int? status;
  dynamic otp;
  String? faviroute;
  String? createdAt;
  String? updatedAt;

  Data({
    this.id,
    this.name,
    this.image,
    this.emailId,
    this.emailVerifiedAt,
    this.deviceToken,
    this.phone,
    this.isVerified,
    this.status,
    this.otp,
    this.faviroute,
    this.createdAt,
    this.updatedAt,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'].toString();
    image = json['image'];
    emailId = json['email_id'];
    emailVerifiedAt = json['email_verified_at'];
    deviceToken = json['device_token'];
    phone = json['phone'];
    isVerified = int.parse(json['is_verified'].toString());
    status = int.parse(json['status'].toString());
    otp = json['otp'];
    faviroute = json['faviroute'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image'] = image;
    data['email_id'] = emailId;
    data['email_verified_at'] = emailVerifiedAt;
    data['device_token'] = deviceToken;
    data['phone'] = phone;
    data['is_verified'] = isVerified;
    data['status'] = status;
    data['otp'] = otp;
    data['faviroute'] = faviroute;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
