import 'package:equatable/equatable.dart';

enum TxDirection { sent, received }

enum TxStatus { pending, confirmed, rejected }

enum TxKind { payment, request }

class TransactionModel extends Equatable {
  final String id;
  final String senderPublicKey;
  final String receiverPublicKey;
  final double amount;
  final TxStatus status;
  final TxKind kind;
  final DateTime clientCreatedAt;
  final DateTime? syncedAt;
  final DateTime? expiresAt;
  final String? lastError;
  final String? counterpartyName;
  final String? counterpartyPhone;
  final String? counterpartyIban;

  const TransactionModel({
    required this.id,
    required this.senderPublicKey,
    required this.receiverPublicKey,
    required this.amount,
    required this.status,
    this.kind = TxKind.payment,
    required this.clientCreatedAt,
    this.syncedAt,
    this.expiresAt,
    this.lastError,
    this.counterpartyName,
    this.counterpartyPhone,
    this.counterpartyIban,
  });

  bool isExpired(DateTime now) =>
      kind == TxKind.request && expiresAt != null && now.isAfter(expiresAt!);

  TxDirection directionFor(String myPublicKey) =>
      senderPublicKey == myPublicKey ? TxDirection.sent : TxDirection.received;

  String counterpartyFor(String myPublicKey) =>
      directionFor(myPublicKey) == TxDirection.sent
      ? receiverPublicKey
      : senderPublicKey;

  @override
  List<Object?> get props => [
    id,
    senderPublicKey,
    receiverPublicKey,
    amount,
    status,
    kind,
    clientCreatedAt,
    syncedAt,
    expiresAt,
    lastError,
    counterpartyName,
    counterpartyPhone,
    counterpartyIban,
  ];

  factory TransactionModel.fromRemote(Map<String, dynamic> json) {
    final rawStatus = json['status'] as String? ?? 'confirmed';
    return TransactionModel(
      id: json['id'] as String,
      senderPublicKey: json['sender_public_key'] as String,
      receiverPublicKey: json['receiver_public_key'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: rawStatus == 'rejected' ? TxStatus.rejected : TxStatus.confirmed,
      clientCreatedAt: DateTime.parse(json['client_created_at'] as String),
      syncedAt: json['synced_at'] != null
          ? DateTime.parse(json['synced_at'] as String)
          : null,
    );
  }

  Map<String, Object?> toCacheRow() => {
    'id': id,
    'sender_public_key': senderPublicKey,
    'receiver_public_key': receiverPublicKey,
    'amount': amount,
    'status': switch (status) {
      TxStatus.confirmed => 'confirmed',
      TxStatus.rejected => 'rejected',
      TxStatus.pending => 'pending',
    },
    'client_created_at': clientCreatedAt.toUtc().toIso8601String(),
    'synced_at': syncedAt?.toUtc().toIso8601String(),
    'counterparty_name': counterpartyName,
    'counterparty_phone': counterpartyPhone,
    'counterparty_iban': counterpartyIban,
  };

  factory TransactionModel.fromCacheRow(Map<String, Object?> row) {
    final s = row['status'] as String? ?? 'confirmed';
    return TransactionModel(
      id: row['id'] as String,
      senderPublicKey: row['sender_public_key'] as String,
      receiverPublicKey: row['receiver_public_key'] as String,
      amount: (row['amount'] as num).toDouble(),
      status: switch (s) {
        'rejected' => TxStatus.rejected,
        'pending' => TxStatus.pending,
        _ => TxStatus.confirmed,
      },
      clientCreatedAt: DateTime.parse(row['client_created_at'] as String),
      syncedAt: row['synced_at'] != null
          ? DateTime.parse(row['synced_at'] as String)
          : null,
      counterpartyName: row['counterparty_name'] as String?,
      counterpartyPhone: row['counterparty_phone'] as String?,
      counterpartyIban: row['counterparty_iban'] as String?,
    );
  }

  /// Build a `pending` transaction view from a row in `pending_transactions`.
  factory TransactionModel.fromPendingRow(Map<String, Object?> row) {
    return TransactionModel(
      id: row['id'] as String,
      senderPublicKey: row['sender_public_key'] as String,
      receiverPublicKey: row['receiver_public_key'] as String,
      amount: (row['amount'] as num).toDouble(),
      status: TxStatus.pending,
      clientCreatedAt: DateTime.parse(row['client_created_at'] as String),
      lastError: row['last_error'] as String?,
      counterpartyName: row['counterparty_name'] as String?,
      counterpartyPhone: row['counterparty_phone'] as String?,
      counterpartyIban: row['counterparty_iban'] as String?,
    );
  }

  /// Build a request view from a row in `pending_requests`.
  factory TransactionModel.fromPendingRequestRow(Map<String, Object?> row) {
    return TransactionModel(
      id: row['id'] as String,
      senderPublicKey: '',
      receiverPublicKey: row['receiver_public_key'] as String,
      amount: (row['amount'] as num).toDouble(),
      status: TxStatus.pending,
      kind: TxKind.request,
      clientCreatedAt: DateTime.parse(row['client_created_at'] as String),
      expiresAt: DateTime.parse(row['expires_at'] as String),
    );
  }

  /// Build a pending view from a row in `incoming_pending`.
  ///
  /// Direction is determined by [directionFor] at render time (comparing
  /// [senderPublicKey] / [receiverPublicKey] against the user's own key),
  /// so the existing [TransactionTile] payment branch renders it correctly
  /// as "Received X.XX · Pending sync" for the receiver.
  factory TransactionModel.fromIncomingPendingRow(Map<String, Object?> row) {
    return TransactionModel(
      id: row['id'] as String,
      senderPublicKey: row['sender_public_key'] as String,
      receiverPublicKey: row['receiver_public_key'] as String,
      amount: (row['amount'] as num).toDouble(),
      status: TxStatus.pending,
      kind: TxKind.payment,
      clientCreatedAt: DateTime.parse(row['client_created_at'] as String),
      lastError: row['last_error'] as String?,
    );
  }
}
