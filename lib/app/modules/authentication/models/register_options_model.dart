class RegisterOptionsModel {
  final List<OptionItem>? stages;
  final List<OptionItem>? divisions;

  RegisterOptionsModel({
    this.stages,
    this.divisions,
  });

  factory RegisterOptionsModel.fromJson(Map<String, dynamic> json) {
    return RegisterOptionsModel(
      stages: (json['stages'] as List<dynamic>?)
          ?.map((e) => OptionItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      divisions: (json['divisions'] as List<dynamic>?)
          ?.map((e) => OptionItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stages': stages?.map((e) => e.toJson()).toList(),
      'divisions': divisions?.map((e) => e.toJson()).toList(),
    };
  }
}

class OptionItem {
  final String? key;
  final String? label;

  OptionItem({
    this.key,
    this.label,
  });

  factory OptionItem.fromJson(Map<String, dynamic> json) {
    return OptionItem(
      key: json['key'] as String?,
      label: json['label'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'label': label,
    };
  }
}
