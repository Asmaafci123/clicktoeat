class UserAddressListModel {
  bool? success;
  List<UserAddressListData>? data;

  UserAddressListModel({this.success, this.data});

  UserAddressListModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(UserAddressListData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class UserAddressListData {
  int? id;
  int? userId;
  String? lat;
  String? lang;
  String? address;
  String? type;
  String? createdAt;
  String? updatedAt;

  UserAddressListData({this.id, this.userId, this.lat, this.lang, this.address, this.type, this.createdAt, this.updatedAt});

  UserAddressListData.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id'].toString());
    userId = int.parse(json['user_id'].toString());
    lat = json['lat'];
    lang = json['lang'];
    address = json['address'];
    type = json['type'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['lat'] = lat;
    data['lang'] = lang;
    data['address'] = address;
    data['type'] = type;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
