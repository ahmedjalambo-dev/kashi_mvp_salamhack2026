import 'package:equatable/equatable.dart';

class PaymentPayload extends Equatable {
  final String id;
  final String senderPublicKey;
  final String receiverPublicKey;
  final double amount;
  final String nonce;
  final DateTime clientCreatedAt;
  final DateTime expiresAt;

  const PaymentPayload({
    required this.id,
    required this.senderPublicKey,
    required this.receiverPublicKey,
    required this.amount,
    required this.nonce,
    required this.clientCreatedAt,
    required this.expiresAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'sender_public_key': senderPublicKey,
        'receiver_public_key': receiverPublicKey,
        'amount': amount,
        'nonce': nonce,
        'client_created_at': clientCreatedAt.toUtc().toIso8601String(),
        'expires_at': expiresAt.toUtc().toIso8601String(),
      };

  factory PaymentPayload.fromJson(Map<String, dynamic> json) => PaymentPayload(
        id: json['id'] as String,
        senderPublicKey: json['sender_public_key'] as String,
        receiverPublicKey: json['receiver_public_key'] as String,
        amount: (json['amount'] as num).toDouble(),
        nonce: json['nonce'] as String,
        clientCreatedAt: DateTime.parse(json['client_created_at'] as String),
        expiresAt: DateTime.parse(json['expires_at'] as String),
      );

  @override
  List<Object?> get props => [
        id,
        senderPublicKey,
        receiverPublicKey,
        amount,
        nonce,
        clientCreatedAt,
        expiresAt,
      ];
}

class SignedEnvelope extends Equatable {
  final PaymentPayload payload;
  final String signature;

  const SignedEnvelope({required this.payload, required this.signature});

  Map<String, dynamic> toJson() => {
        'payload': payload.toJson(),
        'signature': signature,
      };

  factory SignedEnvelope.fromJson(Map<String, dynamic> json) => SignedEnvelope(
        payload: PaymentPayload.fromJson(
          (json['payload'] as Map).cast<String, dynamic>(),
        ),
        signature: json['signature'] as String,
      );

  @override
  List<Object?> get props => [payload, signature];
}
