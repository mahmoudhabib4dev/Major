class SubscriptionDetailsModel {
  final String? planName;
  final String? startDate;
  final String? endDate;

  SubscriptionDetailsModel({
    this.planName,
    this.startDate,
    this.endDate,
  });

  factory SubscriptionDetailsModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionDetailsModel(
      planName: json['plan_name'] as String?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plan_name': planName,
      'start_date': startDate,
      'end_date': endDate,
    };
  }

  // Check if user has an active subscription
  bool get hasSubscription {
    return planName != null &&
           planName!.isNotEmpty &&
           startDate != null &&
           endDate != null;
  }

  // Check if subscription is expired
  bool get isExpired {
    if (endDate == null || endDate!.isEmpty) return false;

    try {
      final endDateTime = DateTime.parse(endDate!);
      return DateTime.now().isAfter(endDateTime);
    } catch (e) {
      return false;
    }
  }
}
