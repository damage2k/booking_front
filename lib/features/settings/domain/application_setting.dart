class ApplicationSetting {
  final int id;
  final String key;
  final String value;
  final String settingType;
  final dynamic typedValue;

  const ApplicationSetting({
    required this.id,
    required this.key,
    required this.value,
    required this.settingType,
    required this.typedValue,
  });

  factory ApplicationSetting.fromJson(Map<String, dynamic> json) {
    return ApplicationSetting(
      id: json['id'],
      key: json['key'],
      value: json['value'],
      settingType: json['settingType'],
      typedValue: json['typedValue'],
    );
  }
}
