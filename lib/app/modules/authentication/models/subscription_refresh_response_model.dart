class SubscriptionRefreshResponseModel {
  final bool success;
  final SubscriptionRefreshData? data;

  SubscriptionRefreshResponseModel({
    required this.success,
    this.data,
  });

  factory SubscriptionRefreshResponseModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionRefreshResponseModel(
      success: json['success'] ?? false,
      data: json['data'] != null
          ? SubscriptionRefreshData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.toJson(),
    };
  }
}

class SubscriptionRefreshData {
  final String? subscriptionStatus; // "pending", "accepted", "cancelled"
  final String? planStatus; // "active", "expired", "none"

  SubscriptionRefreshData({
    this.subscriptionStatus,
    this.planStatus,
  });

  factory SubscriptionRefreshData.fromJson(Map<String, dynamic> json) {
    return SubscriptionRefreshData(
      subscriptionStatus: json['subscription_status'],
      planStatus: json['plan_status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subscription_status': subscriptionStatus,
      'plan_status': planStatus,
    };
  }

  // Helper methods for status checks
  bool get isPending => subscriptionStatus == 'pending';
  bool get isAccepted => subscriptionStatus == 'accepted';
  bool get isCancelled => subscriptionStatus == 'cancelled';
  bool get isActive => planStatus == 'active';
  bool get isExpired => planStatus == 'expired';
  bool get hasNoSubscription => planStatus == 'none';
}
