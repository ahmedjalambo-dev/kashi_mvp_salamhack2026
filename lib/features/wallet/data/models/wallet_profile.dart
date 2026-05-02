import 'package:equatable/equatable.dart';

class WalletProfile extends Equatable {
  const WalletProfile({
    required this.displayName,
    required this.phone,
    required this.iban,
  });

  final String displayName;
  final String phone;
  final String iban;

  Map<String, dynamic> toJson() => {
    'display_name': displayName,
    'phone': phone,
    'iban': iban,
  };

  factory WalletProfile.fromJson(Map<String, dynamic> json) => WalletProfile(
    displayName: json['display_name'] as String,
    phone: json['phone'] as String,
    iban: json['iban'] as String,
  );

  @override
  List<Object?> get props => [displayName, phone, iban];
}
