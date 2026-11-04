import '../helper.dart';

// ignore_for_file: public_member_api_docs

final List<int> cmdLookup = _unpackCommandLookupTable();

const _insertLengthNBits = [
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, //
  0x02, 0x02, 0x03, 0x03, 0x04, 0x04, 0x05, 0x05, //
  0x06, 0x07, 0x08, 0x09, 0x0A, 0x0C, 0x0E, 0x18, //
];

const _copyLengthNBits = [
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, //
  0x01, 0x01, 0x02, 0x02, 0x03, 0x03, 0x04, 0x04, //
  0x05, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x18, //
];

List<int> _unpackCommandLookupTable() {
  final cmdLookup = createInt16List(2816);
  final insertLengthOffsets = createInt16List(24);
  final copyLengthOffsets = createInt16List(24);

  copyLengthOffsets[0] = 2;

  for (var i = 0; i < 23; ++i) {
    insertLengthOffsets[i + 1] =
        insertLengthOffsets[i] + (1 << _insertLengthNBits[i]);
    copyLengthOffsets[i + 1] =
        copyLengthOffsets[i] + (1 << _copyLengthNBits[i]);
  }

  for (var cmdCode = 0; cmdCode < 704; ++cmdCode) {
    var rangeIdx = cmdCode >> 6;
    var distanceContextOffset = -4;

    if (rangeIdx >= 2) {
      rangeIdx -= 2;
      distanceContextOffset = 0;
    }

    final insertCode =
        (((0x29850 >> (rangeIdx * 2)) & 0x3) << 3) | ((cmdCode >> 3) & 7);
    final copyCode = (((0x26244 >> (rangeIdx * 2)) & 0x3) << 3) | (cmdCode & 7);
    final copyLengthOffset = copyLengthOffsets[copyCode];
    final distanceContext = distanceContextOffset +
        (copyLengthOffset > 4 ? 3 : copyLengthOffset - 2);
    final index = cmdCode * 4;

    cmdLookup[index + 0] =
        _insertLengthNBits[insertCode] | (_copyLengthNBits[copyCode] << 8);
    cmdLookup[index + 1] = insertLengthOffsets[insertCode];
    cmdLookup[index + 2] = copyLengthOffsets[copyCode];
    cmdLookup[index + 3] = distanceContext;
  }

  return cmdLookup;
}
