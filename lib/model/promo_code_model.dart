class PromoCodeModel {
  bool? success;
  List<PromoCodeListData>? data;

  PromoCodeModel({this.success, this.data});

  PromoCodeModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(PromoCodeListData.fromJson(v));
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

class PromoCodeListData {
  int? id;
  String? name;
  String? promoCode;
  String? image;
  int? displayCustomerApp;
  String? vendorId;
  String? customerId;
  int? isFlat;
  String? maxUser;
  int? countMaxUser;
  int? flatDiscount;
  String? discountType;
  int? discount;
  String? maxDiscAmount;
  String? minOrderAmount;
  int? maxCount;
  int? countMaxCount;
  String? maxOrder;
  int? countMaxOrder;
  String? couponType;
  String? description;
  String? startEndDate;
  String? displayText;
  int? status;
  String? createdAt;
  String? updatedAt;

  PromoCodeListData(
      {this.id,
      this.name,
      this.promoCode,
      this.image,
      this.displayCustomerApp,
      this.vendorId,
      this.customerId,
      this.isFlat,
      this.maxUser,
      this.countMaxUser,
      this.flatDiscount,
      this.discountType,
      this.discount,
      this.maxDiscAmount,
      this.minOrderAmount,
      this.maxCount,
      this.countMaxCount,
      this.maxOrder,
      this.countMaxOrder,
      this.couponType,
      this.description,
      this.startEndDate,
      this.displayText,
      this.status,
      this.createdAt,
      this.updatedAt});

  PromoCodeListData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'].toString();
    promoCode = json['promo_code'];
    image = json['image'];
    displayCustomerApp = int.parse(json['display_customer_app'].toString());
    vendorId = json['vendor_id'];
    customerId = json['customer_id'];
    isFlat = int.parse(json['isFlat'].toString());
    maxUser = json['max_user'];
    countMaxUser = int.parse(json['count_max_user'].toString());
    flatDiscount = json['flatDiscount'] != null ? int.parse(json['flatDiscount'].toString()) : null;
    discountType = json['discountType'];
    discount = int.parse(json['discount'].toString());
    maxDiscAmount = json['max_disc_amount'];
    minOrderAmount = json['min_order_amount'];
    maxCount = int.parse(json['max_count'].toString());
    countMaxCount = int.parse(json['count_max_count'].toString());
    maxOrder = json['max_order'];
    countMaxOrder = int.parse(json['count_max_order'].toString());
    couponType = json['coupen_type'];
    description = json['description'];
    startEndDate = json['start_end_date'];
    displayText = json['display_text'];
    status = int.parse(json['status'].toString());
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['promo_code'] = promoCode;
    data['image'] = image;
    data['display_customer_app'] = displayCustomerApp;
    data['vendor_id'] = vendorId;
    data['customer_id'] = customerId;
    data['isFlat'] = isFlat;
    data['max_user'] = maxUser;
    data['count_max_user'] = countMaxUser;
    data['flatDiscount'] = flatDiscount;
    data['discountType'] = discountType;
    data['discount'] = discount;
    data['max_disc_amount'] = maxDiscAmount;
    data['min_order_amount'] = minOrderAmount;
    data['max_count'] = maxCount;
    data['count_max_count'] = countMaxCount;
    data['max_order'] = maxOrder;
    data['count_max_order'] = countMaxOrder;
    data['coupen_type'] = couponType;
    data['description'] = description;
    data['start_end_date'] = startEndDate;
    data['display_text'] = displayText;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
