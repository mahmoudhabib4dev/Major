class BankAccountsResponseModel {
  final bool? success;
  final List<BankAccount>? data;
  final String? message;

  BankAccountsResponseModel({
    this.success,
    this.data,
    this.message,
  });

  factory BankAccountsResponseModel.fromJson(dynamic json) {
    // Handle direct array response
    if (json is List) {
      return BankAccountsResponseModel(
        success: true,
        data: json
            .map((e) => BankAccount.fromJson(e as Map<String, dynamic>))
            .toList(),
        message: null,
      );
    }

    // Handle object with data field
    return BankAccountsResponseModel(
      success: json['success'] as bool?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => BankAccount.fromJson(e as Map<String, dynamic>))
          .toList(),
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.map((e) => e.toJson()).toList(),
      'message': message,
    };
  }
}

class BankAccount {
  final int? id;
  final String? bankName;
  final String? accountNumber;
  final String? accountHolderName;
  final String? iban;
  final String? logoUrl;
  final String? currency;
  final double? minimumDeposit;
  final String? formattedMinimumDeposit;

  BankAccount({
    this.id,
    this.bankName,
    this.accountNumber,
    this.accountHolderName,
    this.iban,
    this.logoUrl,
    this.currency,
    this.minimumDeposit,
    this.formattedMinimumDeposit,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: json['id'] as int?,
      bankName: json['name'] as String? ?? json['bank_name'] as String?,
      accountNumber: json['account_number'] as String?,
      accountHolderName: json['account_holder_name'] as String?,
      iban: json['iban'] as String?,
      logoUrl: json['logo'] as String? ?? json['logo_url'] as String?,
      currency: json['currency'] as String?,
      minimumDeposit: (json['minimum_deposit'] as num?)?.toDouble(),
      formattedMinimumDeposit: json['formatted_minimum_deposit'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bank_name': bankName,
      'account_number': accountNumber,
      'account_holder_name': accountHolderName,
      'iban': iban,
      'logo_url': logoUrl,
      'currency': currency,
      'minimum_deposit': minimumDeposit,
      'formatted_minimum_deposit': formattedMinimumDeposit,
    };
  }

  // Helper method to get display name
  String get displayName {
    return bankName ?? 'Unknown Bank';
  }

  // Helper method to get account info for display
  String get accountInfo {
    return accountNumber ?? iban ?? '';
  }
}
