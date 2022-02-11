class SingleOrderDetailsModel {
  bool? success;
  Data? data;

  SingleOrderDetailsModel({this.success, this.data});

  SingleOrderDetailsModel.fromJson(Map<String, dynamic> json) {
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
  dynamic tax;
  String? orderId;
  int? vendorId;
  int? amount;
  int? deliveryPersonId;
  String? orderStatus;
  int? deliveryCharge;
  int? addressId;
  int? promoCodeId;
  int? promoCodePrice;
  int? userId;
  int? vendorDiscountPrice;
  DeliveryPerson? deliveryPerson;
  Vendor? vendor;
  User? user;
  UserAddress? userAddress;
  List<OrderItems>? orderItems;

  Data(
      {this.id,
      this.orderId,
      this.tax,
      this.vendorId,
      this.amount,
      this.deliveryCharge,
      this.deliveryPersonId,
      this.orderStatus,
      this.addressId,
      this.promoCodeId,
      this.promoCodePrice,
      this.userId,
      this.vendorDiscountPrice,
      this.deliveryPerson,
      this.vendor,
      this.user,
      this.userAddress,
      this.orderItems});

  Data.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id'].toString());
    orderId = json['order_id'];
    vendorId = int.parse(json['vendor_id'].toString());
    amount = int.parse(json['amount'].toString());
    tax = json['tax'];
    deliveryPersonId = json['delivery_person_id'] != null ? int.parse(json['delivery_person_id'].toString()) : json['delivery_person_id'];
    orderStatus = json['order_status'];
    deliveryCharge = int.parse(json['delivery_charge'].toString());
    addressId = int.parse(json['address_id'].toString());
    promoCodeId = json['promocode_id'] != null ? int.parse(json['promocode_id'].toString()) : json['promocode_id'];
    promoCodePrice = int.parse(json['promocode_price'].toString());
    userId = int.parse(json['user_id'].toString());
    vendorDiscountPrice = json['vendor_discount_price'] != null ? int.parse(json['vendor_discount_price'].toString()) : json['vendor_discount_price'];
    deliveryPerson = json['delivery_person'] != null ? DeliveryPerson.fromJson(json['delivery_person']) : null;
    vendor = json['vendor'] != null ? Vendor.fromJson(json['vendor']) : null;
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    userAddress = json['user_address'] != null ? UserAddress.fromJson(json['user_address']) : null;
    if (json['orderItems'] != null) {
      orderItems = [];
      json['orderItems'].forEach((v) {
        orderItems!.add(OrderItems.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['order_id'] = orderId;
    data['vendor_id'] = vendorId;
    data['delivery_person_id'] = deliveryPersonId;
    data['amount'] = amount;
    data['tax'] = tax;
    data['order_status'] = orderStatus;
    data['address_id'] = addressId;
    data['promocode_id'] = promoCodeId;
    data['promocode_price'] = promoCodePrice;
    data['user_id'] = userId;
    data['vendor_discount_price'] = vendorDiscountPrice;
    if (deliveryPerson != null) {
      data['delivery_person'] = deliveryPerson!.toJson();
    }
    if (vendor != null) {
      data['vendor'] = vendor!.toJson();
    }
    if (user != null) {
      data['user'] = user!.toJson();
    }
    if (userAddress != null) {
      data['user_address'] = userAddress!.toJson();
    }
    if (orderItems != null) {
      data['orderItems'] = orderItems!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DeliveryPerson {
  String? firstName;
  String? lastName;
  String? image;
  int? deliveryZone;

  DeliveryPerson({this.firstName, this.lastName, this.image, this.deliveryZone});

  DeliveryPerson.fromJson(Map<String, dynamic> json) {
    firstName = json['first_name'].toString();
    lastName = json['last_name'].toString();
    image = json['image'];
    deliveryZone = int.parse(json['deliveryzone'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['image'] = image;
    data['deliveryzone'] = deliveryZone;
    return data;
  }
}

class Vendor {
  String? name;
  String? mapAddress;
  String? image;
  String? lat;
  String? lang;
  List<Null>? cuisine;
  dynamic rate;
  String? tax;
  int? review;

  Vendor({this.name, this.mapAddress, this.image, this.lat, this.lang, this.cuisine, this.rate, this.review});

  Vendor.fromJson(Map<String, dynamic> json) {
    name = json['name'].toString();
    mapAddress = json['map_address'];
    image = json['image'];
    lat = json['lat'];
    tax = json['tax'];
    lang = json['lang'];
    if (json['cuisine'] != null) {
      cuisine = [];
      // json['cuisine'].forEach((v) { cuisine.add(new Null.fromJson(v)); });
    }
    rate = json['rate'];
    review = int.parse(json['review'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['map_address'] = mapAddress;
    data['image'] = image;
    data['tax'] = tax;
    data['lat'] = lat;
    data['lang'] = lang;
    if (cuisine != null) {
      // data['cuisine'] = this.cuisine.map((v) => v.toJson()).toList();
    }
    data['rate'] = rate;
    data['review'] = review;
    return data;
  }
}

class Cuisine {
  Cuisine();

  Cuisine.fromJson(Map<String, dynamic> json);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    return data;
  }
}

class User {
  int? id;
  String? name;
  String? image;
  String? emailId;
  Null emailVerifiedAt;
  String? deviceToken;
  String? phone;
  int? isVerified;
  int? status;
  int? otp;
  String? faviroute;
  String? createdAt;
  String? updatedAt;

  User({this.id, this.name, this.image, this.emailId, this.emailVerifiedAt, this.deviceToken, this.phone, this.isVerified, this.status, this.otp, this.faviroute, this.createdAt, this.updatedAt});

  User.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id'].toString());
    name = json['name'];
    image = json['image'];
    emailId = json['email_id'];
    emailVerifiedAt = json['email_verified_at'];
    deviceToken = json['device_token'];
    phone = json['phone'];
    isVerified = int.parse(json['is_verified'].toString());
    status = int.parse(json['status'].toString());
    otp = int.parse(json['otp'].toString());
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

class UserAddress {
  String? address;
  String? lat;
  String? lang;

  UserAddress({this.address, this.lat, this.lang});

  UserAddress.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    lat = json['lat'];
    lang = json['lang'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['address'] = address;
    data['lat'] = lat;
    data['lang'] = lang;
    return data;
  }
}

/*class OrderItems {
  int id;
  // String custimization;
  int item;
  int price;
  int qty;
  String itemName;

  OrderItems({this.id,  this.item, this.price, this.qty, this.itemName});

  OrderItems.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    // custimization = json['custimization'];
    item = json['item'];
    price = json['price'];
    qty = json['qty'];
    itemName = json['itemName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    // data['custimization'] = this.custimization;
    data['item'] = this.item;
    data['price'] = this.price;
    data['qty'] = this.qty;
    data['itemName'] = this.itemName;
    return data;
  }
}*/

class OrderItems {
  int? id;
  int? orderId;
  int? item;
  int? price;
  int? qty;
  List<Custimization>? custimization;
  String? createdAt;
  String? updatedAt;
  String? itemName;

  OrderItems({this.id, this.orderId, this.item, this.price, this.qty, this.custimization, this.createdAt, this.updatedAt, this.itemName});

  OrderItems.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id'].toString());
    orderId = int.parse(json['order_id'].toString());
    item = int.parse(json['item'].toString());
    price = int.parse(json['price'].toString());
    qty = int.parse(json['qty'].toString());
    if (json['custimization'] != null) {
      custimization = [];
      json['custimization'].forEach((v) {
        custimization!.add(Custimization.fromJson(v));
      });
    }
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    itemName = json['itemName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['order_id'] = orderId;
    data['item'] = item;
    data['price'] = price;
    data['qty'] = qty;
    if (custimization != null) {
      data['custimization'] = custimization!.map((v) => v.toJson()).toList();
    }
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['itemName'] = itemName;
    return data;
  }
}

class Custimization {
  String? mainMenu;
  CustimizationData? data;

  Custimization({this.mainMenu, this.data});

  Custimization.fromJson(Map<String, dynamic> json) {
    mainMenu = json['main_menu'];
    data = json['data'] != null ? CustimizationData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['main_menu'] = mainMenu;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class CustimizationData {
  String? name;
  String? price;

  CustimizationData({this.name, this.price});

  CustimizationData.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    price = json['price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['price'] = price;
    return data;
  }
}
