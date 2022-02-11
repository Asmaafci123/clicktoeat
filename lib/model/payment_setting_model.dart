class PaymentSettingModel {
  bool? success;
  Data? data;

  PaymentSettingModel({this.success, this.data});

  PaymentSettingModel.fromJson(Map<String, dynamic> json) {
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
  int? cod;
  int? stripe;
  int? razorpay;
  int? paypal;
  int? flutterWave;
  int? wallet;
  String? stripePublishKey;
  String? stripeSecretKey;
  String? paypalProduction;
  String? paypalSandbox;
  String? paypalClientId;
  String? paypalSecretKey;
  String? razorpayPublishKey;
  String? publicKey;
  String? createdAt;
  String? updatedAt;

  Data(
      {this.id,
      this.cod,
      this.stripe,
      this.razorpay,
      this.paypal,
      this.flutterWave,
      this.wallet,
      this.stripePublishKey,
      this.stripeSecretKey,
      this.paypalProduction,
      this.paypalSandbox,
      this.paypalClientId,
      this.paypalSecretKey,
      this.razorpayPublishKey,
      this.publicKey,
      this.createdAt,
      this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id'].toString());
    cod = int.parse(json['cod'].toString());
    stripe = int.parse(json['stripe'].toString());
    razorpay = int.parse(json['razorpay'].toString());
    paypal = int.parse(json['paypal'].toString());
    flutterWave = int.parse(json['flutterwave'].toString());
    wallet = int.parse(json['wallet'].toString());
    stripePublishKey = json['stripe_publish_key'];
    stripeSecretKey = json['stripe_secret_key'];
    paypalProduction = json['paypal_production'];
    paypalSandbox = json['paypal_sendbox'];
    paypalClientId = json['paypal_client_id'];
    paypalSecretKey = json['paypal_secret_key'];
    razorpayPublishKey = json['razorpay_publish_key'];
    publicKey = json['public_key'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['cod'] = cod;
    data['stripe'] = stripe;
    data['razorpay'] = razorpay;
    data['paypal'] = paypal;
    data['flutterwave'] = flutterWave;
    data['wallet'] = wallet;
    data['stripe_publish_key'] = stripePublishKey;
    data['stripe_secret_key'] = stripeSecretKey;
    data['paypal_production'] = paypalProduction;
    data['paypal_sendbox'] = paypalSandbox;
    data['paypal_client_id'] = paypalClientId;
    data['paypal_secret_key'] = paypalSecretKey;
    data['razorpay_publish_key'] = razorpayPublishKey;
    data['public_key'] = publicKey;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
