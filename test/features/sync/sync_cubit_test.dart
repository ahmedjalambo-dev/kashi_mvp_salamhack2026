import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kashi_mvp_salamhack2026/src/core/network/error_model.dart';
import 'package:kashi_mvp_salamhack2026/src/core/network/result.dart';
import 'package:kashi_mvp_salamhack2026/src/core/services/connectivity_service.dart';
import 'package:kashi_mvp_salamhack2026/src/features/sync/data/repositories/sync_repository.dart';
import 'package:kashi_mvp_salamhack2026/src/features/sync/state/sync_cubit.dart';
import 'package:kashi_mvp_salamhack2026/src/features/sync/state/sync_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockSyncRepository extends Mock implements SyncRepository {}

class _MockConnectivityService extends Mock implements ConnectivityService {}

void main() {
  late _MockSyncRepository repository;
  late _MockConnectivityService connectivity;

  setUp(() {
    repository = _MockSyncRepository();
    connectivity = _MockConnectivityService();

    when(() => connectivity.onStatusChange)
        .thenAnswer((_) => const Stream.empty());
    when(() => repository.requeueDuplicateRejections())
        .thenAnswer((_) async {});
    when(() => repository.pendingCount()).thenAnswer((_) async => 0);
  });

  SyncCubit buildCubit() => SyncCubit(
        repository: repository,
        connectivity: connectivity,
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
        const SyncIdle(synced: 1, failed: 0),
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
        const SyncIdle(synced: 0, failed: 1),
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
