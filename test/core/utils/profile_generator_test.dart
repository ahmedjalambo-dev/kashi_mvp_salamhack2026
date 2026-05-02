import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:kashi_mvp_salamhack2026/core/utils/profile_generator.dart';

void main() {
  group('ProfileGenerator', () {
    test('phone matches Palestinian format', () {
      final gen = ProfileGenerator(Random(42));
      for (var i = 0; i < 20; i++) {
        final profile = gen.generate();
        expect(
          RegExp(r'^\+970 5[0269] \d{3} \d{4}$').hasMatch(profile.phone),
          isTrue,
          reason: 'phone "${profile.phone}" does not match +970 5X XXX XXXX',
        );
      }
    });

    test('IBAN is 29 chars and matches PS92 format', () {
      final gen = ProfileGenerator(Random(7));
      for (var i = 0; i < 20; i++) {
        final profile = gen.generate();
        expect(profile.iban.length, 29);
        expect(
          RegExp(r'^PS92[A-Z]{4}\d{21}$').hasMatch(profile.iban),
          isTrue,
          reason: 'IBAN "${profile.iban}" does not match PS92XXXX + 21 digits',
        );
      }
    });

    test('displayName is non-empty', () {
      final gen = ProfileGenerator(Random(99));
      for (var i = 0; i < 10; i++) {
        expect(gen.generate().displayName, isNotEmpty);
      }
    });

    test('multiple calls produce variety', () {
      final gen = ProfileGenerator(Random(1));
      final names = {for (var i = 0; i < 50; i++) gen.generate().displayName};
      expect(names.length, greaterThan(1));
    });
  });
}
