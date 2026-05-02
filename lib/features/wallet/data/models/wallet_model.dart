import 'package:equatable/equatable.dart';

import 'wallet_profile.dart';

class WalletModel extends Equatable {
  final String id;
  final String publicKey;
  final double balance;
  final WalletProfile? profile;

  const WalletModel({
    required this.id,
    required this.publicKey,
    required this.balance,
    this.profile,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    final dn = json['display_name'] as String?;
    final ph = json['phone'] as String?;
    final ib = json['iban'] as String?;
    final profile = (dn != null && ph != null && ib != null)
        ? WalletProfile(displayName: dn, phone: ph, iban: ib)
        : null;
    return WalletModel(
      id: json['id'] as String,
      publicKey: json['public_key'] as String,
      balance: (json['balance'] as num).toDouble(),
      profile: profile,
    );
  }

  @override
  List<Object?> get props => [id, publicKey, balance, profile];
}
