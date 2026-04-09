class PaymentCardModel {
  final String? id;
  final String userId;
  final String cardHolder;
  final String lastFour;
  final String expiryDate;
  final String cardType;
  final bool isDefault;

  PaymentCardModel({
    this.id,
    required this.userId,
    required this.cardHolder,
    required this.lastFour,
    required this.expiryDate,
    required this.cardType,
    this.isDefault = false,
  });

  factory PaymentCardModel.fromJson(Map<String, dynamic> json) {
    return PaymentCardModel(
      id: json['id'],
      userId: json['user_id'],
      cardHolder: json['card_holder'] ?? '',
      lastFour: json['last_four'] ?? '',
      expiryDate: json['expiry_date'] ?? '',
      cardType: json['card_type'] ?? '',
      isDefault: json['is_default'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'user_id': userId,
      'card_holder': cardHolder,
      'last_four': lastFour,
      'expiry_date': expiryDate,
      'card_type': cardType,
      'is_default': isDefault,
    };
    if (id != null) data['id'] = id;
    return data;
  }
}
