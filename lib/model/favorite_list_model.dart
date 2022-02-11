class FavoriteListModel {
  bool? success;
  List<FavoriteListData>? data;

  FavoriteListModel({this.success, this.data});

  FavoriteListModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(FavoriteListData.fromJson(v));
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

class FavoriteListData {
  int? id;
  String? name;
  String? image;
  String? lat;
  String? lang;
  String? cuisineId;
  String? vendorType;
  int? distance;
  List<Cuisine>? cuisine;
  dynamic rate;
  int? review;

  FavoriteListData({this.id, this.name, this.image, this.lat, this.lang, this.cuisineId, this.vendorType, this.distance, this.cuisine, this.rate, this.review});

  FavoriteListData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'].toString();
    image = json['image'];
    lat = json['lat'];
    lang = json['lang'];
    cuisineId = json['cuisine_id'];
    vendorType = json['vendor_type'];
    distance = json['distance'];
    if (json['cuisine'] != null) {
      cuisine = [];
      json['cuisine'].forEach((v) {
        cuisine!.add(Cuisine.fromJson(v));
      });
    }
    rate = json['rate'];
    review = json['review'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image'] = image;
    data['lat'] = lat;
    data['lang'] = lang;
    data['cuisine_id'] = cuisineId;
    data['vendor_type'] = vendorType;
    data['distance'] = distance;
    if (cuisine != null) {
      data['cuisine'] = cuisine!.map((v) => v.toJson()).toList();
    }
    data['rate'] = rate;
    data['review'] = review;
    return data;
  }
}

class Cuisine {
  String? name;
  String? image;

  Cuisine({this.name, this.image});

  Cuisine.fromJson(Map<String, dynamic> json) {
    name = json['name'].toString();
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['image'] = image;
    return data;
  }
}
