import 'dart:io';

// Request model for storing subscription
class SubscriptionStoreRequest {
  final int? planId;
  final int? bankAccountId;
  final File? transferReceipt;
  final String? couponCode;
  final String? referenceNumber;
  final String? paymentMethod;
  final String? transactionId;
  final bool calculateOnly;

  SubscriptionStoreRequest({
    this.planId,
    this.bankAccountId,
    this.transferReceipt,
    this.couponCode,
    this.referenceNumber,
    this.paymentMethod,
    this.transactionId,
    this.calculateOnly = false,
  });

  // For apply coupon (calculate only)
  factory SubscriptionStoreRequest.calculateOnly({
    int? planId,
    String? couponCode,
  }) {
    return SubscriptionStoreRequest(
      planId: planId,
      couponCode: couponCode,
      paymentMethod: 'bank_transfer', // Required by API even for calculation
      calculateOnly: true,
    );
  }

  // For complete payment
  factory SubscriptionStoreRequest.completePayment({
    required int planId,
    required int bankAccountId,
    required File transferReceipt,
    String? couponCode,
    String? referenceNumber,
    String? paymentMethod,
    String? transactionId,
  }) {
    return SubscriptionStoreRequest(
      planId: planId,
      bankAccountId: bankAccountId,
      transferReceipt: transferReceipt,
      couponCode: couponCode,
      referenceNumber: referenceNumber,
      paymentMethod: paymentMethod,
      transactionId: transactionId,
      calculateOnly: false,
    );
  }
}

// Response model for subscription store
class SubscriptionStoreResponse {
  final bool? success;
  final String? message;
  final SubscriptionStoreData? data;

  SubscriptionStoreResponse({
    this.success,
    this.message,
    this.data,
  });

  factory SubscriptionStoreResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionStoreResponse(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: json['data'] != null
          ? SubscriptionStoreData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

// Data model for subscription store response
class SubscriptionStoreData {
  final int? subscriptionId;
  final String? status;
  final double? originalPrice;
  final double? discount;
  final double? finalPrice;
  final String? formattedOriginalPrice;
  final String? formattedDiscount;
  final String? formattedFinalPrice;

  SubscriptionStoreData({
    this.subscriptionId,
    this.status,
    this.originalPrice,
    this.discount,
    this.finalPrice,
    this.formattedOriginalPrice,
    this.formattedDiscount,
    this.formattedFinalPrice,
  });

  factory SubscriptionStoreData.fromJson(Map<String, dynamic> json) {
    return SubscriptionStoreData(
      subscriptionId: json['subscription_id'] as int?,
      status: json['status'] as String?,
      originalPrice: (json['original_price'] as num?)?.toDouble(),
      discount: (json['discount'] as num?)?.toDouble(),
      finalPrice: (json['final_price'] as num?)?.toDouble(),
      formattedOriginalPrice: json['formatted_original_price'] as String?,
      formattedDiscount: json['formatted_discount'] as String?,
      formattedFinalPrice: json['formatted_final_price'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subscription_id': subscriptionId,
      'status': status,
      'original_price': originalPrice,
      'discount': discount,
      'final_price': finalPrice,
      'formatted_original_price': formattedOriginalPrice,
      'formatted_discount': formattedDiscount,
      'formatted_final_price': formattedFinalPrice,
    };
  }
}
