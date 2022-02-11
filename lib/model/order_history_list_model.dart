class OrderHistoryListModel {
  bool? success;
  List<OrderHistoryData>? data;

  OrderHistoryListModel({this.success, this.data});

  OrderHistoryListModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(OrderHistoryData.fromJson(v));
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

class OrderHistoryData {
  int? id;
  int? amount;
  int? vendorId;
  String? orderStatus;
  int? deliveryPersonId;
  int? deliveryCharge;
  String? date;
  String? time;
  int? addressId;
  DeliveryPerson? deliveryPerson;
  Vendor? vendor;
  Null user;
  List<OrderItems>? orderItems;
  UserAddress? userAddress;

  OrderHistoryData(
      {this.id,
      this.amount,
      this.vendorId,
      this.orderStatus,
      this.deliveryPersonId,
      this.deliveryCharge,
      this.date,
      this.time,
      this.addressId,
      this.deliveryPerson,
      this.vendor,
      this.user,
      this.orderItems,
      this.userAddress});

  OrderHistoryData.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id'].toString());
    amount = int.parse(json['amount'].toString());
    vendorId = int.parse(json['vendor_id'].toString());
    orderStatus = json['order_status'];
    deliveryPersonId = json['delivery_person_id'] != null ? int.parse(json['delivery_person_id'].toString()) : json['delivery_person_id'];
    deliveryCharge = int.parse(json['delivery_charge'].toString());
    date = json['date'];
    time = json['time'];
    addressId = int.parse(json['address_id'].toString());
    deliveryPerson = json['delivery_person'] != null ? DeliveryPerson.fromJson(json['delivery_person']) : null;
    vendor = json['vendor'] != null ? Vendor.fromJson(json['vendor']) : null;
    user = json['user'];
    if (json['orderItems'] != null) {
      orderItems = [];
      json['orderItems'].forEach((v) {
        orderItems!.add(OrderItems.fromJson(v));
      });
    }
    userAddress = json['user_address'] != null ? UserAddress.fromJson(json['user_address']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['amount'] = amount;
    data['vendor_id'] = vendorId;
    data['order_status'] = orderStatus;
    data['delivery_person_id'] = deliveryPersonId;
    data['delivery_charge'] = deliveryCharge;
    data['date'] = date;
    data['time'] = time;
    data['address_id'] = addressId;
    if (deliveryPerson != null) {
      data['delivery_person'] = deliveryPerson!.toJson();
    }
    if (vendor != null) {
      data['vendor'] = vendor!.toJson();
    }
    data['user'] = user;
    if (orderItems != null) {
      data['orderItems'] = orderItems!.map((v) => v.toJson()).toList();
    }
    if (userAddress != null) {
      data['user_address'] = userAddress!.toJson();
    }
    return data;
  }
}

class DeliveryPerson {
  String? name;
  String? image;
  String? contact;

  DeliveryPerson({this.name, this.image, this.contact});

  DeliveryPerson.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    image = json['image'];
    contact = json['contact'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['image'] = image;
    data['contact'] = contact;
    return data;
  }
}

class Vendor {
  int? id;
  int? userId;
  String? name;
  String? vendorLogo;
  String? emailId;
  String? image;
  String? password;
  String? contact;
  String? cuisineId;
  String? address;
  String? lat;
  String? lang;
  String? mapAddress;
  String? minOrderAmount;
  String? forTwoPerson;
  String? avgDeliveryTime;
  String? licenseNumber;
  String? adminCommissionType;
  String? adminCommissionValue;
  String? vendorType;
  String? timeSlot;
  String? tax;
  Null deliveryTypeTimeSlot;
  int? isExplorer;
  int? isTop;
  int? vendorOwnDriver;
  Null paymentOption;
  int? status;
  String? vendorLanguage;
  String? createdAt;
  String? updatedAt;
  List<Cuisine>? cuisine;
  double? rate;
  int? review;

  Vendor(
      {this.id,
      this.userId,
      this.name,
      this.vendorLogo,
      this.emailId,
      this.image,
      this.password,
      this.contact,
      this.cuisineId,
      this.address,
      this.lat,
      this.lang,
      this.mapAddress,
      this.minOrderAmount,
      this.forTwoPerson,
      this.avgDeliveryTime,
      this.licenseNumber,
      this.adminCommissionType,
      this.adminCommissionValue,
      this.vendorType,
      this.timeSlot,
      this.tax,
      this.deliveryTypeTimeSlot,
      this.isExplorer,
      this.isTop,
      this.vendorOwnDriver,
      this.paymentOption,
      this.status,
      this.vendorLanguage,
      this.createdAt,
      this.updatedAt,
      this.cuisine,
      this.rate,
      this.review});

  Vendor.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id'].toString());
    userId = int.parse(json['user_id'].toString());
    name = json['name'];
    vendorLogo = json['vendor_logo'];
    emailId = json['email_id'];
    image = json['image'];
    password = json['password'];
    contact = json['contact'];
    cuisineId = json['cuisine_id'];
    address = json['address'];
    lat = json['lat'];
    lang = json['lang'];
    mapAddress = json['map_address'];
    minOrderAmount = json['min_order_amount'];
    forTwoPerson = json['for_two_person'];
    avgDeliveryTime = json['avg_delivery_time'];
    licenseNumber = json['license_number'];
    adminCommissionType = json['admin_comission_type'];
    adminCommissionValue = json['admin_comission_value'];
    vendorType = json['vendor_type'];
    timeSlot = json['time_slot'];
    tax = json['tax'];
    deliveryTypeTimeSlot = json['delivery_type_timeSlot'];
    isExplorer = int.parse(json['isExplorer'].toString());
    isTop = int.parse(json['isTop'].toString());
    vendorOwnDriver = int.parse(json['vendor_own_driver'].toString());
    paymentOption = json['payment_option'];
    status = int.parse(json['status'].toString());
    vendorLanguage = json['vendor_language'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    if (json['cuisine'] != null) {
      cuisine = [];
      json['cuisine'].forEach((v) {
        cuisine!.add(Cuisine.fromJson(v));
      });
    }
    rate = json['rate'].toDouble();
    review = json['review'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['name'] = name;
    data['vendor_logo'] = vendorLogo;
    data['email_id'] = emailId;
    data['image'] = image;
    data['password'] = password;
    data['contact'] = contact;
    data['cuisine_id'] = cuisineId;
    data['address'] = address;
    data['lat'] = lat;
    data['lang'] = lang;
    data['map_address'] = mapAddress;
    data['min_order_amount'] = minOrderAmount;
    data['for_two_person'] = forTwoPerson;
    data['avg_delivery_time'] = avgDeliveryTime;
    data['license_number'] = licenseNumber;
    data['admin_comission_type'] = adminCommissionType;
    data['admin_comission_value'] = adminCommissionValue;
    data['vendor_type'] = vendorType;
    data['time_slot'] = timeSlot;
    data['tax'] = tax;
    data['delivery_type_timeSlot'] = deliveryTypeTimeSlot;
    data['isExplorer'] = isExplorer;
    data['isTop'] = isTop;
    data['vendor_own_driver'] = vendorOwnDriver;
    data['payment_option'] = paymentOption;
    data['status'] = status;
    data['vendor_language'] = vendorLanguage;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
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

class OrderItems {
  int? id;
  int? orderId;
  int? item;
  int? price;
  int? qty;
  List<Custimization>? customization;
  String? createdAt;
  String? updatedAt;
  String? itemName;

  OrderItems({this.id, this.orderId, this.item, this.price, this.qty, this.customization, this.createdAt, this.updatedAt, this.itemName});

  OrderItems.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id'].toString());
    orderId = int.parse(json['order_id'].toString());
    item = int.parse(json['item'].toString());
    price = int.parse(json['price'].toString());
    qty = int.parse(json['qty'].toString());
    if (json['custimization'] != null) {
      customization = [];
      json['custimization'].forEach((v) {
        customization!.add(Custimization.fromJson(v));
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
    if (customization != null) {
      data['custimization'] = customization!.map((v) => v.toJson()).toList();
    }
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['itemName'] = itemName;
    return data;
  }
}

class Custimization {
  String? mainMenu;
  OrderHistoryData? data;

  Custimization({this.mainMenu, this.data});

  Custimization.fromJson(Map<String, dynamic> json) {
    mainMenu = json['main_menu'];
    data = json['data'] != null ? OrderHistoryData.fromJson(json['data']) : null;
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

class Data {
  String? name;
  String? price;

  Data({this.name, this.price});

  Data.fromJson(Map<String, dynamic> json) {
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

class UserAddress {
  String? lat;
  String? lang;
  String? address;

  UserAddress({this.lat, this.lang, this.address});

  UserAddress.fromJson(Map<String, dynamic> json) {
    lat = json['lat'];
    lang = json['lang'];
    address = json['address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lat'] = lat;
    data['lang'] = lang;
    data['address'] = address;
    return data;
  }
}
