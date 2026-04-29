import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kashi_mvp_salamhack2026/src/core/crypto/ecdsa_signer.dart';
import 'package:kashi_mvp_salamhack2026/src/core/crypto/payload_codec.dart';
import 'package:kashi_mvp_salamhack2026/src/core/network/error_handler.dart';
import 'package:kashi_mvp_salamhack2026/src/core/network/result.dart';
import 'package:kashi_mvp_salamhack2026/src/core/services/secure_storage.dart';
import 'package:kashi_mvp_salamhack2026/src/features/send/data/models/payment_payload.dart';
import 'package:kashi_mvp_salamhack2026/src/features/send/data/repositories/send_repository.dart';
import 'package:kashi_mvp_salamhack2026/src/features/send/data/services/payment_signer.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uuid/uuid.dart';

class _MockSecureStorage extends Mock implements SecureStorage {}

void main() {
  late EcdsaSigner signer;
  late EcdsaKeyPair pair;
  late PaymentSigner paymentSigner;
  late _MockSecureStorage storage;
  late SendRepository repo;

  setUp(() {
    signer = EcdsaSigner();
    pair = signer.generateKeyPair();
    paymentSigner = PaymentSigner(signer: signer, codec: const PayloadCodec());
    storage = _MockSecureStorage();
    when(() => storage.read(any())).thenAnswer((_) async => pair.privateKeyBase64);
    repo = SendRepository(
      paymentSigner: paymentSigner,
      secureStorage: storage,
      uuid: const Uuid(),
      errors: const ErrorHandler(),
    );
  });

  test('produces a verifiable signed envelope', () async {
    final result = await repo.buildSignedQr(
      senderPublicKey: pair.publicKeyBase64,
      receiverPublicKey: 'receiver-pub',
      amount: 12.5,
    );
    expect(result, isA<Success<String>>());
    final qr = (result as Success<String>).data;
    final envelope = SignedEnvelope.fromJson(
      (jsonDecode(utf8.decode(base64Decode(qr))) as Map).cast<String, dynamic>(),
    );
    expect(envelope.payload.amount, 12.5);
    expect(paymentSigner.verify(envelope.payload, envelope.signature), isTrue);
  });

  test('rejects non-positive amount', () async {
    final result = await repo.buildSignedQr(
      senderPublicKey: pair.publicKeyBase64,
      receiverPublicKey: 'r',
      amount: 0,
    );
    expect(result, isA<Failure<String>>());
  });

  test('fails when private key is missing', () async {
    when(() => storage.read(any())).thenAnswer((_) async => null);
    final result = await repo.buildSignedQr(
      senderPublicKey: pair.publicKeyBase64,
      receiverPublicKey: 'r',
      amount: 1,
    );
    expect(result, isA<Failure<String>>());
  });
}
