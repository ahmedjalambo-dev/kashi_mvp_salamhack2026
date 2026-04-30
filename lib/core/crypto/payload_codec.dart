import 'dart:convert';
import 'dart:typed_data';

class PayloadCodec {
  const PayloadCodec();

  /// Canonical JSON: keys sorted lexicographically, no whitespace.
  /// Required so sender and receiver hash the same bytes.
  String canonicalEncode(Map<String, dynamic> payload) {
    final sorted = _sort(payload);
    return jsonEncode(sorted);
  }

  Uint8List canonicalBytes(Map<String, dynamic> payload) {
    return Uint8List.fromList(utf8.encode(canonicalEncode(payload)));
  }

  dynamic _sort(dynamic value) {
    if (value is Map) {
      final keys = value.keys.cast<String>().toList()..sort();
      return {for (final k in keys) k: _sort(value[k])};
    }
    if (value is List) {
      return value.map(_sort).toList();
    }
    return value;
  }
}
