class ComplaintResponseModel {
  final bool status;
  final String message;
  final int? complaintId;

  ComplaintResponseModel({
    required this.status,
    required this.message,
    this.complaintId,
  });

  factory ComplaintResponseModel.fromJson(Map<String, dynamic> json) {
    return ComplaintResponseModel(
      // If we got a successful HTTP response (200/201), it's a success
      status: json['status'] ?? json['success'] ?? true,
      message: json['message'] ?? '',
      complaintId: json['complaint_id'],
    );
  }
}
