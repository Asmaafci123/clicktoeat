class SingleRestaurantsDetailsModel {
  bool? success;
  Data? data;

  SingleRestaurantsDetailsModel({this.success, this.data});

  SingleRestaurantsDetailsModel.fromJson(Map<String, dynamic> json) {
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
  Vendor? vendor;
  List<RestaurantsDetailsMenuListData>? menu;
  VendorDiscount? vendorDiscount;
  List<DeliveryTimeslot>? deliveryTimeslot;
  List<PickUpTimeslot>? pickUpTimeslot;
  List<SellingTimeslot>? sellingTimeslot;

  Data(
      {this.vendor,
      this.menu,
      this.vendorDiscount,
      this.deliveryTimeslot,
      this.pickUpTimeslot,
      this.sellingTimeslot});

  Data.fromJson(Map<String, dynamic> json) {
    vendor = json['vendor'] != null ? Vendor.fromJson(json['vendor']) : null;
    if (json['menu'] != null) {
      menu = [];
      json['menu'].forEach((v) {
        menu!.add(RestaurantsDetailsMenuListData.fromJson(v));
      });
    }
    vendorDiscount = json['vendor_discount'] != null
        ? VendorDiscount.fromJson(json['vendor_discount'])
        : null;
    if (json['delivery_timeslot'] != null) {
      deliveryTimeslot = [];
      json['delivery_timeslot'].forEach((v) {
        deliveryTimeslot!.add(DeliveryTimeslot.fromJson(v));
      });
    }
    if (json['pick_up_timeslot'] != null) {
      pickUpTimeslot = [];
      json['pick_up_timeslot'].forEach((v) {
        pickUpTimeslot!.add(PickUpTimeslot.fromJson(v));
      });
    }
    if (json['selling_timeslot'] != null) {
      sellingTimeslot = [];
      json['selling_timeslot'].forEach((v) {
        sellingTimeslot!.add(SellingTimeslot.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (vendor != null) {
      data['vendor'] = vendor!.toJson();
    }
    if (menu != null) {
      data['menu'] = menu!.map((v) => v.toJson()).toList();
    }
    if (vendorDiscount != null) {
      data['vendor_discount'] = vendorDiscount!.toJson();
    }
    if (deliveryTimeslot != null) {
      data['delivery_timeslot'] =
          deliveryTimeslot!.map((v) => v.toJson()).toList();
    }
    if (pickUpTimeslot != null) {
      data['pick_up_timeslot'] =
          pickUpTimeslot!.map((v) => v.toJson()).toList();
    }
    if (sellingTimeslot != null) {
      data['selling_timeslot'] =
          sellingTimeslot!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Vendor {
  String? image;
  String? name;
  String? mapAddress;
  String? forTwoPerson;
  String? vendorType;
  String? lat;
  String? lang;
  String? avgDeliveryTime;
  String? cuisineId;
  List<Cuisine>? cuisine;
  dynamic rate;
  int? review;
  int? id;
  String? tax;

  Vendor({
    this.image,
    this.name,
    this.mapAddress,
    this.forTwoPerson,
    this.vendorType,
    this.lat,
    this.lang,
    this.avgDeliveryTime,
    this.cuisineId,
    this.cuisine,
    this.rate,
    this.id,
    this.tax,
    this.review,
  });

  Vendor.fromJson(Map<String, dynamic> json) {
    image = json['image'];
    id = json['id'];
    tax = json['tax'];
    name = json['name'];
    mapAddress = json['map_address'];
    forTwoPerson = json['for_two_person'];
    vendorType = json['vendor_type'];
    lat = json['lat'];
    lang = json['lang'];
    avgDeliveryTime = json['avg_delivery_time'];
    cuisineId = json['cuisine_id'];
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
    data['image'] = image;
    data['name'] = name;
    data['map_address'] = mapAddress;
    data['for_two_person'] = forTwoPerson;
    data['vendor_type'] = vendorType;
    data['cuisine_id'] = cuisineId;
    data['avg_delivery_time'] = avgDeliveryTime;
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

class RestaurantsDetailsMenuListData {
  int? id;
  String? name;
  String? image;
  List<SubMenuListData>? submenu;
  String? menuCategory;

  RestaurantsDetailsMenuListData(
      {this.id, this.name, this.image, this.submenu, this.menuCategory});

  RestaurantsDetailsMenuListData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'].toString();
    image = json['image'];
    if (json['submenu'] != null) {
      submenu = [];
      json['submenu'].forEach((v) {
        submenu!.add(SubMenuListData.fromJson(v));
      });
    }
    menuCategory = json['menuCategory'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image'] = image;
    if (submenu != null) {
      data['submenu'] = submenu!.map((v) => v.toJson()).toList();
    }
    data['menuCategory'] = menuCategory;
    return data;
  }
}

class SubMenuListData {
  int? id;
  String? name;
  String? image;
  String? price;
  String? type;
  List<Custimization>? custimization;
  bool? isAdded = false;
  int count = 0;
  int itemQty = 0;
  String? description;
  bool? isRepeatCustomization = false;
  int? tempQty;
  String? qtyReset;
  int? itemResetValue;
  int? availableItem;

  SubMenuListData({
    this.id,
    this.name,
    this.image,
    this.price,
    this.type,
    this.custimization,
    this.description,
    required this.count,
    this.isAdded,
    this.isRepeatCustomization,
    this.qtyReset,
    this.itemResetValue,
    this.availableItem,
  });

  SubMenuListData.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id'].toString());
    name = json['name'].toString();
    type = json['type'].toString();
    image = json['image'];
    price = json['price'];
    qtyReset = json['qty_reset'];
    itemResetValue = json['item_reset_value'];
    availableItem = json['availabel_item'];
    description = json['description'];
    if (json['custimization'] != null) {
      custimization = [];
      json['custimization'].forEach((v) {
        custimization!.add(Custimization.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['type'] = type;
    data['image'] = image;
    data['price'] = price;
    data['qty_reset'] = qtyReset;
    data['item_reset_value'] = itemResetValue;
    data['availabel_item'] = availableItem;
    data['description'] = description;
    if (custimization != null) {
      data['custimization'] = custimization!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Custimization {
  int? id;
  String? name;
  String? customizationItem;
  String? type;

  Custimization({this.id, this.name, this.customizationItem, this.type});

  Custimization.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id'].toString());
    name = json['name'].toString();
    customizationItem = json['custimazation_item'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['custimazation_item'] = customizationItem;
    data['type'] = type;
    return data;
  }
}

class VendorDiscount {
  int? id;
  String? type;
  int? discount;
  String? minItemAmount;
  String? maxDiscountAmount;
  String? startEndDate;

  VendorDiscount(
      {this.id,
      this.type,
      this.discount,
      this.minItemAmount,
      this.maxDiscountAmount,
      this.startEndDate});

  VendorDiscount.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id'].toString());
    type = json['type'];
    discount = int.parse(json['discount'].toString());
    minItemAmount = json['min_item_amount'];
    maxDiscountAmount = json['max_discount_amount'];
    startEndDate = json['start_end_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['type'] = type;
    data['discount'] = discount;
    data['min_item_amount'] = minItemAmount;
    data['max_discount_amount'] = maxDiscountAmount;
    data['start_end_date'] = startEndDate;
    return data;
  }
}

class DeliveryTimeslot {
  int? id;
  String? dayIndex;
  List<PeriodList>? periodList;
  int? status;

  DeliveryTimeslot({this.id, this.dayIndex, this.periodList, this.status});

  DeliveryTimeslot.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id'].toString());
    dayIndex = json['day_index'];
    if (json['period_list'] != null) {
      periodList = [];
      json['period_list'].forEach((v) {
        periodList!.add(PeriodList.fromJson(v));
      });
    }
    status = int.parse(json['status'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['day_index'] = dayIndex;
    if (periodList != null) {
      data['period_list'] = periodList!.map((v) => v.toJson()).toList();
    }
    data['status'] = status;
    return data;
  }
}

class PeriodList {
  String? startTime;
  String? endTime;
  String? newStartTime;
  String? newEndTime;

  PeriodList(
      {this.startTime, this.endTime, this.newStartTime, this.newEndTime});

  PeriodList.fromJson(Map<String, dynamic> json) {
    startTime = json['start_time'];
    endTime = json['end_time'];
    newStartTime = json['new_start_time'];
    newEndTime = json['new_end_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['start_time'] = startTime;
    data['end_time'] = endTime;
    data['new_start_time'] = newStartTime;
    data['new_end_time'] = newEndTime;
    return data;
  }
}

class PickUpTimeslot {
  int? id;
  String? dayIndex;
  List<PeriodList>? periodList;
  int? status;

  PickUpTimeslot({this.id, this.dayIndex, this.periodList, this.status});

  PickUpTimeslot.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    dayIndex = json['day_index'];
    if (json['period_list'] != null) {
      periodList = [];
      json['period_list'].forEach((v) {
        periodList!.add(PeriodList.fromJson(v));
      });
    }
    status = int.parse(json['status'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['day_index'] = dayIndex;
    if (periodList != null) {
      data['period_list'] = periodList!.map((v) => v.toJson()).toList();
    }
    data['status'] = status;
    return data;
  }
}

class SellingTimeslot {
  int? id;
  String? dayIndex;
  String? periodList;
  int? status;

  SellingTimeslot({this.id, this.dayIndex, this.periodList, this.status});

  SellingTimeslot.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id'].toString());
    dayIndex = json['day_index'];
    periodList = json['period_list'];
    status = int.parse(json['status'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['day_index'] = dayIndex;
    data['period_list'] = periodList;
    data['status'] = status;
    return data;
  }
}
