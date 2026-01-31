class SupportCenterResponseModel {
  final SupportContacts supportContacts;
  final List<Faq> faqs;

  SupportCenterResponseModel({
    required this.supportContacts,
    required this.faqs,
  });

  factory SupportCenterResponseModel.fromJson(Map<String, dynamic> json) {
    return SupportCenterResponseModel(
      supportContacts: SupportContacts.fromJson(json['support_contacts'] as Map<String, dynamic>),
      faqs: (json['faqs'] as List<dynamic>?)
              ?.map((e) => Faq.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'support_contacts': supportContacts.toJson(),
      'faqs': faqs.map((e) => e.toJson()).toList(),
    };
  }
}

class SupportContacts {
  final String mobile;
  final String whatsapp;
  final String email;
  final String website;

  SupportContacts({
    required this.mobile,
    required this.whatsapp,
    required this.email,
    required this.website,
  });

  factory SupportContacts.fromJson(Map<String, dynamic> json) {
    return SupportContacts(
      mobile: json['mobile'] ?? '',
      whatsapp: json['whatsapp'] ?? '',
      email: json['email'] ?? '',
      website: json['website'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mobile': mobile,
      'whatsapp': whatsapp,
      'email': email,
      'website': website,
    };
  }
}

class Faq {
  final int id;
  final String question;
  final String answer;

  Faq({
    required this.id,
    required this.question,
    required this.answer,
  });

  factory Faq.fromJson(Map<String, dynamic> json) {
    return Faq(
      id: json['id'] ?? 0,
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
    };
  }
}
