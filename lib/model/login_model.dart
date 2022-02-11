class LoginModel {
  bool? success;
  Data? data;

  LoginModel({this.success, this.data});

  LoginModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
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
  String? phone;
  String? phoneCode;
  int? isVerified;
  int? status;
  int? otp;
  String? faviroute;
  String? createdAt;
  String? updatedAt;
  String? token;
  String? language;
  String? accountName;
  String? accountNumber;
  String? micrCode;
  String? ifscCode;
  List<Roles>? roles;

  Data(
      {this.id,
      this.name,
      this.image,
      this.emailId,
      this.emailVerifiedAt,
      this.phone,
      this.phoneCode,
      this.isVerified,
      this.status,
      this.otp,
      this.faviroute,
      this.createdAt,
      this.updatedAt,
      this.token,
      this.language,
      this.accountName,
      this.accountNumber,
      this.micrCode,
      this.ifscCode,
      this.roles});

  Data.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id'].toString());
    name = json['name'].toString();
    image = json['image'];
    emailId = json['email_id'].toString();
    emailVerifiedAt = json['email_verified_at'];
    phone = json['phone'];
    phoneCode = json['phone_code'];
    isVerified = int.parse(json['is_verified'].toString());
    status = int.parse(json['status'].toString());
    otp = int.parse(json['otp'].toString());
    faviroute = json['faviroute'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    token = json['token'];

    if (json['language'] != null) {
      language = json['language'];
    }

    if (json['account_name'] != null) {
      accountName = json['account_name'];
    }

    if (json['micr_code'] != null) {
      micrCode = json['micr_code'];
    }

    if (json['ifsc_code'] != null) {
      ifscCode = json['ifsc_code'];
    }

    if (json['account_number'] != null) {
      accountNumber = json['account_number'];
    }

    if (json['roles'] != null) {
      roles = [];
      json['roles'].forEach((v) {
        roles!.add(Roles.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image'] = image;
    data['email_id'] = emailId;
    data['email_verified_at'] = emailVerifiedAt;
    data['phone'] = phone;
    data['phone_code'] = phoneCode;
    data['is_verified'] = isVerified;
    data['status'] = status;
    data['otp'] = otp;
    data['faviroute'] = faviroute;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['token'] = token;

    if (ifscCode != null) {
      data['ifsc_code'] = ifscCode;
    }
    if (micrCode != null) {
      data['micr_code'] = micrCode;
    }
    if (language != null) {
      data['language'] = language;
    }

    if (accountNumber != null) {
      data['account_number'] = accountNumber;
    }

    if (accountNumber != null) {
      data['account_number'] = accountNumber;
    }

    if (roles != null) {
      data['roles'] = roles!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Roles {
  int? id;
  String? title;
  String? createdAt;
  String? updatedAt;
  Pivot? pivot;

  Roles({this.id, this.title, this.createdAt, this.updatedAt, this.pivot});

  Roles.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id'].toString());
    title = json['title'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    pivot = json['pivot'] != null ? Pivot.fromJson(json['pivot']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (pivot != null) {
      data['pivot'] = pivot!.toJson();
    }
    return data;
  }
}

class Pivot {
  int? userId;
  int? roleId;

  Pivot({this.userId, this.roleId});

  Pivot.fromJson(Map<String, dynamic> json) {
    userId = int.tryParse(json['user_id'].toString());
    roleId = int.tryParse(json['role_id'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['role_id'] = roleId;
    return data;
  }
}
