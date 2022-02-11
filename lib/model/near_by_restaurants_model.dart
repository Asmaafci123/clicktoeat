class NearByRestaurantModel {
  bool? success;
  List<NearByRestaurantListData>? data;

  NearByRestaurantModel({this.success, this.data});

  NearByRestaurantModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(NearByRestaurantListData.fromJson(v));
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

class NearByRestaurantListData {
  int? id;
  String? image;
  String? name;
  String? lat;
  String? lang;
  String? cuisineId;
  String? vendorType;
  String? avgDeliveryTime;
  bool? like;
  List<Cuisine>? cuisine;
  dynamic rate;
  int? review;

  NearByRestaurantListData({
    this.id,
    this.image,
    this.name,
    this.lat,
    this.lang,
    this.avgDeliveryTime,
    this.cuisineId,
    this.vendorType,
    this.like,
    this.cuisine,
    this.rate,
    this.review,
  });

  NearByRestaurantListData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'];
    name = json['name'].toString();
    lat = json['lat'];
    lang = json['lang'];
    avgDeliveryTime = json['avg_delivery_time'];
    cuisineId = json['cuisine_id'];
    vendorType = json['vendor_type'];
    like = json['like'];

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
    data['avg_delivery_time'] = avgDeliveryTime;
    data['cuisine_id'] = cuisineId;
    data['vendor_type'] = vendorType;
    data['like'] = like;
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
    print("the name is ${json['name']}");
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['image'] = image;
    return data;
  }
}
