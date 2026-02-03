// Response model for apply coupon endpoint
class ApplyCouponResponse {
  final int? couponId;
  final double? originalPrice;
  final double? discountValue;
  final double? finalPrice;

  ApplyCouponResponse({
    this.couponId,
    this.originalPrice,
    this.discountValue,
    this.finalPrice,
  });

  factory ApplyCouponResponse.fromJson(Map<String, dynamic> json) {
    return ApplyCouponResponse(
      couponId: json['coupon_id'] as int?,
      originalPrice: json['original_price'] != null
          ? double.tryParse(json['original_price'].toString())
          : null,
      discountValue: json['discount_value'] != null
          ? (json['discount_value'] is int
              ? (json['discount_value'] as int).toDouble()
              : double.tryParse(json['discount_value'].toString()))
          : null,
      finalPrice: json['final_price'] != null
          ? (json['final_price'] is int
              ? (json['final_price'] as int).toDouble()
              : double.tryParse(json['final_price'].toString()))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coupon_id': couponId,
      'original_price': originalPrice,
      'discount_value': discountValue,
      'final_price': finalPrice,
    };
  }
}
