class ApiErrorModel {
  final String? message;
  final int? statusCode;
  final Map<String, dynamic>? errors;
  final bool isHtmlError;
  final String? htmlContent;

  ApiErrorModel({
    this.message,
    this.statusCode,
    this.errors,
    this.isHtmlError = false,
    this.htmlContent,
  });

  factory ApiErrorModel.fromJson(Map<String, dynamic> json) {
    return ApiErrorModel(
      message: json['message'] as String?,
      statusCode: json['status_code'] as int?,
      errors: json['errors'] as Map<String, dynamic>?,
      isHtmlError: false,
    );
  }

  factory ApiErrorModel.fromHtml(String html, int statusCode) {
    return ApiErrorModel(
      message: 'Server returned an HTML error response',
      statusCode: statusCode,
      isHtmlError: true,
      htmlContent: html,
    );
  }

  String get displayMessage {
    if (message != null && message!.isNotEmpty) {
      return message!;
    }
    if (errors != null && errors!.isNotEmpty) {
      return errors!.values.first.toString();
    }
    return 'حدث خطأ غير متوقع';
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'status_code': statusCode,
      'errors': errors,
      'is_html_error': isHtmlError,
      'html_content': htmlContent,
    };
  }
}
