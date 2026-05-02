import 'dart:math';

import '../../features/wallet/data/models/wallet_profile.dart';

const _firstNames = [
  'Ahmad', 'Yousef', 'Omar', 'Sami', 'Khalil',
  'Tariq', 'Rami', 'Hassan', 'Nader', 'Faris',
  'Layla', 'Mariam', 'Nour', 'Salma', 'Rana',
  'Hana', 'Dina', 'Reem', 'Sara', 'Lina',
];

const _familyNames = [
  'Al-Amin', 'Barakat', 'Jabr', 'Khalil', 'Mansour',
  'Nasser', 'Qasim', 'Saleh', 'Taha', 'Zaki',
  'Hamdan', 'Arafat', 'Bishara', 'Daoud', 'Farhat',
];

const _mobileSuffixes = ['0', '2', '6', '9'];

const _bankCodes = ['APAB', 'PALS', 'JORD', 'ARAB', 'ISDB', 'CARE', 'BNKP'];

class ProfileGenerator {
  ProfileGenerator([Random? random]) : _random = random ?? Random.secure();
  final Random _random;

  WalletProfile generate() => WalletProfile(
    displayName: _name(),
    phone: _phone(),
    iban: _iban(),
  );

  String _name() {
    final first = _firstNames[_random.nextInt(_firstNames.length)];
    final family = _familyNames[_random.nextInt(_familyNames.length)];
    return '$first $family';
  }

  String _phone() {
    final suffix = _mobileSuffixes[_random.nextInt(_mobileSuffixes.length)];
    final d1 = _random.nextInt(10);
    final d2 = _random.nextInt(10);
    final d3 = _random.nextInt(10);
    final d4 = _random.nextInt(10);
    final d5 = _random.nextInt(10);
    final d6 = _random.nextInt(10);
    final d7 = _random.nextInt(10);
    return '+970 5$suffix $d1$d2$d3 $d4$d5$d6$d7';
  }

  String _iban() {
    final bank = _bankCodes[_random.nextInt(_bankCodes.length)];
    final digits = List.generate(21, (_) => _random.nextInt(10)).join();
    return 'PS92$bank$digits';
  }
}
