class ExploreRestaurantListModel {
  bool? success;
  List<ExploreRestaurantsListData>? data;

  ExploreRestaurantListModel({this.success, this.data});

  ExploreRestaurantListModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(ExploreRestaurantsListData.fromJson(v));
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

class ExploreRestaurantsListData {
  int? id;
  String? image;
  String? name;
  String? lat;
  String? lang;
  String? avgDeliveryTime;
  String? cuisineId;
  String? vendorType;
  int? distance;
  bool? like;
  List<Cuisine>? cuisine;
  dynamic rate;
  int? review;

  ExploreRestaurantsListData({
    this.id,
    this.image,
    this.name,
    this.lat,
    this.lang,
    this.avgDeliveryTime,
    this.cuisineId,
    this.vendorType,
    this.distance,
    this.like,
    this.cuisine,
    this.rate,
    this.review,
  });

  ExploreRestaurantsListData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'];
    name = json['name'].toString();
    lat = json['lat'];
    lang = json['lang'];
    avgDeliveryTime = json['avg_delivery_time'];
    cuisineId = json['cuisine_id'];
    vendorType = json['vendor_type'];
    distance = json['distance'];
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
    data['distance'] = distance;
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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['image'] = image;
    return data;
  }
}
