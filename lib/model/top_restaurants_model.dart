class TopRestaurantsListModel {
  bool? success;
  List<TopRestaurantsListData>? data;

  TopRestaurantsListModel({this.success, this.data});

  TopRestaurantsListModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(TopRestaurantsListData.fromJson(v));
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

class TopRestaurantsListData {
  int? id;
  String? image;
  String? name;
  String? lat;
  String? lang;
  String? avgDeliveryTime;
  String? vendorType;
  String? cuisineId;
  int? distance;
  bool? like;
  List<Cuisine>? cuisine;
  dynamic rate;
  int? review;

  TopRestaurantsListData({
    this.id,
    this.image,
    this.name,
    this.lat,
    this.lang,
    this.avgDeliveryTime,
    this.vendorType,
    this.cuisineId,
    this.distance,
    this.like,
    this.cuisine,
    this.rate,
    this.review,
  });

  TopRestaurantsListData.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id'].toString());
    image = json['image'];
    name = json['name'].toString();
    lat = json['lat'];
    lang = json['lang'];
    avgDeliveryTime = json['avg_delivery_time'];
    vendorType = json['vendor_type'];
    cuisineId = json['cuisine_id'];
    distance = int.parse(json['distance'].toString());
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
    data['vendor_type'] = vendorType;
    data['cuisine_id'] = cuisineId;
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
