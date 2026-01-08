class SocialLinksResponseModel {
  final List<SocialLink> socialLinks;

  SocialLinksResponseModel({
    required this.socialLinks,
  });

  factory SocialLinksResponseModel.fromJson(Map<String, dynamic> json) {
    return SocialLinksResponseModel(
      socialLinks: (json['social_links'] as List<dynamic>?)
              ?.map((item) => SocialLink.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'social_links': socialLinks.map((link) => link.toJson()).toList(),
    };
  }
}

class SocialLink {
  final String platform;
  final String url;

  SocialLink({
    required this.platform,
    required this.url,
  });

  factory SocialLink.fromJson(Map<String, dynamic> json) {
    return SocialLink(
      platform: json['platform'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'platform': platform,
      'url': url,
    };
  }
}
