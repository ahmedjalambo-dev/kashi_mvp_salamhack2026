import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kashi_mvp_salamhack2026/core/network/error_model.dart';
import 'package:kashi_mvp_salamhack2026/core/network/result.dart';
import 'package:kashi_mvp_salamhack2026/core/services/connectivity_service.dart';
import 'package:kashi_mvp_salamhack2026/features/sync/data/repositories/sync_repository.dart';
import 'package:kashi_mvp_salamhack2026/features/sync/state/sync_cubit.dart';
import 'package:kashi_mvp_salamhack2026/features/sync/state/sync_state.dart';
import 'package:kashi_mvp_salamhack2026/features/wallet/data/repositories/wallet_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockSyncRepository extends Mock implements SyncRepository {}

class _MockConnectivityService extends Mock implements ConnectivityService {}

class _MockWalletRepository extends Mock implements WalletRepository {}

void main() {
  late _MockSyncRepository repository;
  late _MockConnectivityService connectivity;
  late _MockWalletRepository walletRepository;

  setUp(() {
    repository = _MockSyncRepository();
    connectivity = _MockConnectivityService();
    walletRepository = _MockWalletRepository();

    when(() => connectivity.onStatusChange)
        .thenAnswer((_) => const Stream.empty());
    when(() => repository.requeueDuplicateRejections())
        .thenAnswer((_) async {});
    when(() => repository.pendingCount()).thenAnswer((_) async => 0);
    when(() => walletRepository.ensureKeyPair())
        .thenAnswer((_) async => 'my-pub-key');
    when(() => repository.pullAndReconcile(any())).thenAnswer(
      (_) async => const Success(ReconcileOutcome(0, null)),
    );
  });

  SyncCubit buildCubit() => SyncCubit(
        repository: repository,
        connectivity: connectivity,
        walletRepository: walletRepository,
      );

  group('SyncCubit.runOnce', () {
    blocTest<SyncCubit, SyncState>(
      'emits [SyncRunning, SyncIdle(synced:1)] on successful drain',
      build: buildCubit,
      setUp: () {
        when(() => repository.drainPending())
            .thenAnswer((_) async => const Success(SyncOutcome(1, 0)));
      },
      act: (c) => c.runOnce(),
      expect: () => [
        const SyncRunning(),
        const SyncIdle(synced: 1, failed: 0, reconciled: 0),
      ],
    );

    blocTest<SyncCubit, SyncState>(
      'emits [SyncRunning, SyncIdle(failed:1)] when one row permanently fails',
      build: buildCubit,
      setUp: () {
        when(() => repository.drainPending())
            .thenAnswer((_) async => const Success(SyncOutcome(0, 1)));
      },
      act: (c) => c.runOnce(),
      expect: () => [
        const SyncRunning(),
        const SyncIdle(synced: 0, failed: 1, reconciled: 0),
      ],
    );

    blocTest<SyncCubit, SyncState>(
      'emits [SyncRunning, SyncFailure] when drainPending returns Failure',
      build: buildCubit,
      setUp: () {
        when(() => repository.drainPending()).thenAnswer(
          (_) async => const Failure(ErrorModel(message: 'network error')),
        );
      },
      act: (c) => c.runOnce(),
      expect: () => [
        const SyncRunning(),
        const SyncFailure('network error'),
      ],
    );

    blocTest<SyncCubit, SyncState>(
      '_running resets after Failure so a second runOnce emits states again',
      build: buildCubit,
      setUp: () {
        when(() => repository.drainPending()).thenAnswer(
          (_) async => const Failure(ErrorModel(message: 'err')),
        );
      },
      act: (c) async {
        await c.runOnce();
        await c.runOnce();
      },
      expect: () => [
        const SyncRunning(),
        const SyncFailure('err'),
        const SyncRunning(),
        const SyncFailure('err'),
      ],
    );

    blocTest<SyncCubit, SyncState>(
      'reconciled count from pullAndReconcile is reflected in SyncIdle',
      build: buildCubit,
      setUp: () {
        when(() => repository.drainPending())
            .thenAnswer((_) async => const Success(SyncOutcome(0, 0)));
        when(() => repository.pullAndReconcile(any())).thenAnswer(
          (_) async => const Success(ReconcileOutcome(2, 900.0)),
        );
      },
      act: (c) => c.runOnce(),
      expect: () => [
        const SyncRunning(),
        const SyncIdle(synced: 0, failed: 0, reconciled: 2),
      ],
    );

    blocTest<SyncCubit, SyncState>(
      'pullAndReconcile failure is swallowed — still emits SyncIdle',
      build: buildCubit,
      setUp: () {
        when(() => repository.drainPending())
            .thenAnswer((_) async => const Success(SyncOutcome(1, 0)));
        when(() => repository.pullAndReconcile(any())).thenAnswer(
          (_) async =>
              const Failure(ErrorModel(message: 'Offline', code: 'OFFLINE')),
        );
      },
      act: (c) => c.runOnce(),
      expect: () => [
        const SyncRunning(),
        const SyncIdle(synced: 1, failed: 0, reconciled: 0),
      ],
    );
  });

  test('closing cubit while drainPending is in flight does not throw', () async {
    final completer = Completer<Result<SyncOutcome>>();
    when(() => repository.drainPending()).thenAnswer((_) => completer.future);

    final cubit = buildCubit();
    unawaited(cubit.runOnce());
    await cubit.close();
    completer.complete(const Success(SyncOutcome(1, 0)));
    // Let microtasks settle — the isClosed guard must prevent a StateError.
    await Future<void>.delayed(Duration.zero);
  });
}
