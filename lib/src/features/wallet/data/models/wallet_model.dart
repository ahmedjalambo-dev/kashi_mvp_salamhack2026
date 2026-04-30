import 'package:equatable/equatable.dart';

class WalletModel extends Equatable {
  final String id;
  final String publicKey;
  final double balance;

  const WalletModel({
    required this.id,
    required this.publicKey,
    required this.balance,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) => WalletModel(
    id: json['id'] as String,
    publicKey: json['public_key'] as String,
    balance: (json['balance'] as num).toDouble(),
  );

  @override
  List<Object?> get props => [id, publicKey, balance];
}
