import 'package:equatable/equatable.dart';

/// A lightweight model for displaying pending transactions in the UI.
class PendingTxDisplay extends Equatable {
  final String id;
  final String senderPublicKey;
  final String receiverPublicKey;
  final double amount;
  final String status;
  final int retryCount;
  final String? lastError;
  final DateTime createdAt;

  const PendingTxDisplay({
    required this.id,
    required this.senderPublicKey,
    required this.receiverPublicKey,
    required this.amount,
    required this.status,
    required this.retryCount,
    this.lastError,
    required this.createdAt,
  });

  factory PendingTxDisplay.fromRow(Map<String, Object?> row) {
    return PendingTxDisplay(
      id: row['id'] as String,
      senderPublicKey: row['sender_public_key'] as String,
      receiverPublicKey: row['receiver_public_key'] as String,
      amount: (row['amount'] as num).toDouble(),
      status: row['status'] as String,
      retryCount: (row['retry_count'] as int?) ?? 0,
      lastError: row['last_error'] as String?,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }

  /// User-friendly status label.
  String get statusLabel => switch (status) {
        'pending_sync' => 'Waiting to sync',
        'syncing' => 'Syncing…',
        'rejected' => 'Rejected',
        'failed_permanently' => 'Failed',
        _ => status,
      };

  /// True if this transaction is still waiting to be synced.
  bool get isPending => status == 'pending_sync' || status == 'syncing';

  @override
  List<Object?> get props => [id, status, retryCount];
}
