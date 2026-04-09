class AddressModel {
  final String? id;
  final String user_id;
  final String title;
  final String city;
  final String street;
  final String house;
  final String apartment;
  final bool isDefault;

  AddressModel({
    this.id,
    required this.user_id,
    required this.title,
    required this.city,
    required this.street,
    required this.house,
    required this.apartment,
    this.isDefault = false,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'],
      user_id: json['user_id'],
      title: json['title'] ?? '',
      city: json['city'] ?? '',
      street: json['street'] ?? '',
      house: json['house'] ?? '',
      apartment: json['apartment'] ?? '',
      isDefault: json['is_default'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'user_id': user_id,
      'title': title,
      'city': city,
      'street': street,
      'house': house,
      'apartment': apartment,
      'is_default': isDefault,
    };
    if (id != null) data['id'] = id;
    return data;
  }
}
