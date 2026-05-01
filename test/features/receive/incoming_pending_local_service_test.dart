import 'package:flutter_test/flutter_test.dart';
import 'package:kashi_mvp_salamhack2026/core/constants/app_constants.dart';
import 'package:kashi_mvp_salamhack2026/core/services/local_db.dart';
import 'package:kashi_mvp_salamhack2026/features/receive/data/services/incoming_pending_local_service.dart';
import 'package:kashi_mvp_salamhack2026/features/send/data/models/payment_payload.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite/sqflite.dart';

class _MockLocalDb extends Mock implements LocalDb {}

class _MockDatabase extends Mock implements Database {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockLocalDb mockDb;
  late _MockDatabase mockDatabase;
  late IncomingPendingLocalService service;

  final now = DateTime.now().toUtc();
  final payload = PaymentPayload(
    id: 'test-id-1',
    senderPublicKey: 'sender-key',
    receiverPublicKey: 'receiver-key',
    amount: 10.0,
    nonce: 'nonce123',
    clientCreatedAt: now,
    expiresAt: now.add(const Duration(hours: 1)),
  );
  final envelope = SignedEnvelope(payload: payload, signature: 'sig123');

  setUp(() {
    mockDb = _MockLocalDb();
    mockDatabase = _MockDatabase();
    service = IncomingPendingLocalService(mockDb);
    when(() => mockDb.database).thenAnswer((_) async => mockDatabase);
  });

  test('insert delegates to Database.insert with correct table', () async {
    when(
      () => mockDatabase.insert(
        any(),
        any(),
        conflictAlgorithm: any(named: 'conflictAlgorithm'),
      ),
    ).thenAnswer((_) async => 1);

    // insert does not use conflictAlgorithm — match without it
    when(() => mockDatabase.insert(any(), any())).thenAnswer((_) async => 1);

    await service.insert(envelope);

    verify(
      () => mockDatabase.insert(AppConstants.incomingPendingTable, any()),
    ).called(1);
  });

  test('markSynced updates status to synced', () async {
    when(
      () => mockDatabase.update(
        any(),
        any(),
        where: any(named: 'where'),
        whereArgs: any(named: 'whereArgs'),
      ),
    ).thenAnswer((_) async => 1);

    await service.markSynced('test-id-1');

    final captured = verify(
      () => mockDatabase.update(
        AppConstants.incomingPendingTable,
        captureAny(),
        where: 'id = ?',
        whereArgs: ['test-id-1'],
      ),
    ).captured;

    expect((captured.first as Map)['status'], 'synced');
  });

  test('markRejected updates status to rejected with reason', () async {
    when(
      () => mockDatabase.update(
        any(),
        any(),
        where: any(named: 'where'),
        whereArgs: any(named: 'whereArgs'),
      ),
    ).thenAnswer((_) async => 1);

    await service.markRejected('test-id-1', 'bad signature');

    final captured = verify(
      () => mockDatabase.update(
        AppConstants.incomingPendingTable,
        captureAny(),
        where: 'id = ?',
        whereArgs: ['test-id-1'],
      ),
    ).captured;

    final row = captured.first as Map;
    expect(row['status'], 'rejected');
    expect(row['last_error'], 'bad signature');
  });

  test('queryPending queries with pending_sync filter', () async {
    when(
      () => mockDatabase.query(
        any(),
        where: any(named: 'where'),
        whereArgs: any(named: 'whereArgs'),
        orderBy: any(named: 'orderBy'),
      ),
    ).thenAnswer((_) async => []);

    await service.queryPending();

    verify(
      () => mockDatabase.query(
        AppConstants.incomingPendingTable,
        where: 'status = ?',
        whereArgs: ['pending_sync'],
        orderBy: 'created_at asc',
      ),
    ).called(1);
  });

  test('pendingCount queries with count aggregate', () async {
    when(
      () => mockDatabase.query(
        any(),
        columns: any(named: 'columns'),
        where: any(named: 'where'),
      ),
    ).thenAnswer(
      (_) async => [
        {'n': 3},
      ],
    );

    final count = await service.pendingCount();
    expect(count, 3);
  });

  test('onChange fires after insert', () async {
    when(() => mockDatabase.insert(any(), any())).thenAnswer((_) async => 1);

    final events = <void>[];
    final sub = service.onChange.listen((_) => events.add(null));

    await service.insert(envelope);
    // Allow any pending microtasks/stream events to run.
    await Future<void>.delayed(Duration.zero);
    expect(events.length, 1);

    await sub.cancel();
  });
}
