class PDFResourceModel {
  final int id;
  final String name;
  final String? pdfFile;
  final String? videoUrl;

  PDFResourceModel({
    required this.id,
    required this.name,
    this.pdfFile,
    this.videoUrl,
  });

  // Check if this resource is a video
  bool get isVideo => videoUrl != null && videoUrl!.isNotEmpty;

  // Check if this resource is a PDF
  bool get isPdf => pdfFile != null && pdfFile!.isNotEmpty;

  factory PDFResourceModel.fromJson(Map<String, dynamic> json) {
    return PDFResourceModel(
      id: json['id'] as int,
      name: json['name'] as String,
      // Support both 'pdf' and 'pdf_file' field names
      pdfFile: (json['pdf'] ?? json['pdf_file']) as String?,
      // Support video field
      videoUrl: json['video'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'pdf_file': pdfFile,
      'video': videoUrl,
    };
  }
}
