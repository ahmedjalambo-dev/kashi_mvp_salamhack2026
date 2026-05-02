import 'package:equatable/equatable.dart';

class PaymentPayload extends Equatable {
  final String id;
  final String senderPublicKey;
  final String receiverPublicKey;
  final double amount;
  final String nonce;
  final DateTime clientCreatedAt;
  final DateTime expiresAt;
  final String senderDisplayName;
  final String senderPhone;
  final String senderIban;

  const PaymentPayload({
    required this.id,
    required this.senderPublicKey,
    required this.receiverPublicKey,
    required this.amount,
    required this.nonce,
    required this.clientCreatedAt,
    required this.expiresAt,
    required this.senderDisplayName,
    required this.senderPhone,
    required this.senderIban,
  });

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'client_created_at': clientCreatedAt.toUtc().toIso8601String(),
    'expires_at': expiresAt.toUtc().toIso8601String(),
    'id': id,
    'nonce': nonce,
    'receiver_public_key': receiverPublicKey,
    'sender_display_name': senderDisplayName,
    'sender_iban': senderIban,
    'sender_phone': senderPhone,
    'sender_public_key': senderPublicKey,
  };

  factory PaymentPayload.fromJson(Map<String, dynamic> json) => PaymentPayload(
    id: json['id'] as String,
    senderPublicKey: json['sender_public_key'] as String,
    receiverPublicKey: json['receiver_public_key'] as String,
    amount: (json['amount'] as num).toDouble(),
    nonce: json['nonce'] as String,
    clientCreatedAt: DateTime.parse(json['client_created_at'] as String),
    expiresAt: DateTime.parse(json['expires_at'] as String),
    senderDisplayName: json['sender_display_name'] as String? ?? '',
    senderPhone: json['sender_phone'] as String? ?? '',
    senderIban: json['sender_iban'] as String? ?? '',
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
    senderDisplayName,
    senderPhone,
    senderIban,
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
