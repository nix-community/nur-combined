import 'dart:typed_data';

// ignore_for_file: public_member_api_docs

extension ListExtension on List<int> {
  void copyWithin(int target, int start, int end) {
    for (var k = start, i = target; k < end; k++, i++) {
      this[i] = this[k];
    }
  }
}

List<int> createInt32List(int length, [int? value]) {
  final data = Int32List(length);

  if (value != null) {
    data.fillRange(0, data.length, value);
  }

  return data;
}

List<int> createInt16List(int length, [int? value]) {
  final data = Int16List(length);

  if (value != null) {
    data.fillRange(0, data.length, value);
  }

  return data;
}

List<int> createInt8List(int length, [int? value]) {
  final data = Int8List(length);

  if (value != null) {
    data.fillRange(0, data.length, value);
  }

  return data;
}

List<int> createUint8List(int length, [int? value]) {
  final data = Uint8List(length);

  if (value != null) {
    data.fillRange(0, data.length, value);
  }

  return data;
}
