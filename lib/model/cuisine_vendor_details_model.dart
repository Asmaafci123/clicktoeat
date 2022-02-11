class CuisineVendorDetailsModel {
  bool? success;
  List<CuisineVendorDetailsListData>? data;

  CuisineVendorDetailsModel({this.success, this.data});

  CuisineVendorDetailsModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(CuisineVendorDetailsListData.fromJson(v));
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

class CuisineVendorDetailsListData {
  int? id;
  String? image;
  String? name;
  String? lat;
  String? lang;
  String? cuisineId;
  String? vendorType;
  List<Cuisine>? cuisine;
  dynamic rate;
  int? review;

  CuisineVendorDetailsListData({this.id, this.image, this.name, this.lat, this.lang, this.cuisineId, this.vendorType, this.cuisine, this.rate, this.review});

  CuisineVendorDetailsListData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'];
    name = json['name'].toString();
    lat = json['lat'];
    lang = json['lang'];
    cuisineId = json['cuisine_id'];
    vendorType = json['vendor_type'];
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
    data['image'] = image;
    data['name'] = name;
    data['lat'] = lat;
    data['lang'] = lang;
    data['cuisine_id'] = cuisineId;
    data['vendor_type'] = vendorType;
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
    name = json['name'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['image'] = image;
    return data;
  }
}
