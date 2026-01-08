class SubscriptionPlansResponseModel {
  final bool? success;
  final List<SubscriptionPlan>? data;
  final String? message;

  SubscriptionPlansResponseModel({
    this.success,
    this.data,
    this.message,
  });

  factory SubscriptionPlansResponseModel.fromJson(dynamic json) {
    // Handle direct array response
    if (json is List) {
      return SubscriptionPlansResponseModel(
        success: true,
        data: json
            .map((e) => SubscriptionPlan.fromJson(e as Map<String, dynamic>))
            .toList(),
        message: null,
      );
    }

    // Handle object with data field
    return SubscriptionPlansResponseModel(
      success: json['success'] as bool?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => SubscriptionPlan.fromJson(e as Map<String, dynamic>))
          .toList(),
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.map((e) => e.toJson()).toList(),
      'message': message,
    };
  }
}

class SubscriptionPlan {
  final int? id;
  final String? planName;
  final double? price;
  final int? durationDays;
  final List<String>? features;
  final String? formattedPrice;

  SubscriptionPlan({
    this.id,
    this.planName,
    this.price,
    this.durationDays,
    this.features,
    this.formattedPrice,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    // Handle features as string or array
    List<String> featuresList = [];
    if (json['features'] != null) {
      if (json['features'] is String) {
        // Split string features by newline or comma
        featuresList = (json['features'] as String)
            .split(RegExp(r'[\n,]'))
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      } else if (json['features'] is List) {
        featuresList = (json['features'] as List<dynamic>)
            .map((e) => e.toString())
            .toList();
      }
    }

    return SubscriptionPlan(
      id: json['id'] as int?,
      planName: json['name'] as String? ?? json['plan_name'] as String?,
      price: (json['price'] is String)
          ? double.tryParse(json['price'] as String)
          : (json['price'] as num?)?.toDouble(),
      durationDays: json['duration_days'] as int?,
      features: featuresList,
      formattedPrice: json['formatted_price'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plan_name': planName,
      'price': price,
      'duration_days': durationDays,
      'features': features,
      'formatted_price': formattedPrice,
    };
  }

  // Helper method to get duration in months
  int get durationMonths {
    if (durationDays == null) return 0;
    return (durationDays! / 30).round();
  }

  // Helper method to get duration label
  String get durationLabel {
    if (durationDays == null) return '';
    return '$durationDays يوم';
  }
}
