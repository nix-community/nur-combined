// ignore_for_file: strict_top_level_inference, prefer_const_constructors
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import '../exception.dart';
import '../helper.dart';
import 'command_lookup.dart';
import 'dictionary.dart';
import 'input_stream.dart';
import 'lookup.dart';
import 'state.dart';
import 'transforms.dart';

const _maxHuffmanTableSize = [
  256, 402, 436, 468, 500, 534, 566, 598, //
  630, 662, 694, 726, 758, 790, 822, 854, //
  886, 920, 952, 984, 1016, 1048, 1080,
];

const _codeLengthCodeOrder = [
  1, 2, 3, 4, 0, 5, 17, 6, //
  16, 7, 8, 9, 10, 11, 12, 13, //
  14, 15,
];

const _distanceShortCodeIndexOffset = [
  0, 3, 2, 1, 0, 0, 0, 0, //
  0, 0, 3, 3, 3, 3, 3, 3, //
];

const _distanceShortCodeValueOffset = [
  0, 0, 0, 0, -1, 1, -2, 2, //
  -3, 3, -1, 1, -2, 2, -3, 3, //
];

const _fixedTable = [
  0x020000, 0x020004, 0x020003, 0x030002, //
  0x020000, 0x020004, 0x020003, 0x040001, //
  0x020000, 0x020004, 0x020003, 0x030002, //
  0x020000, 0x020004, 0x020003, 0x040005, //
];

const _blockLengthOffset = [
  1, 5, 9, 13, 17, 25, 33, 41, //
  49, 65, 81, 97, 113, 145, 177, 209, //
  241, 305, 369, 497, 753, 1265, 2289, 4337, //
  8433, 16625,
];

const _blockLengthNBits = [
  2, 2, 2, 2, 3, 3, 3, 3, //
  4, 4, 4, 4, 5, 5, 5, 5, //
  6, 6, 7, 8, 9, 10, 11, 12, //
  13, 24, //
];

int _log2floor(int i) {
  var result = -1;
  var step = 16;

  while (step > 0) {
    if ((i >>> step) != 0) {
      result += step;
      i = i >>> step;
    }

    step = step >> 1;
  }

  return result + i;
}

const _logBitness = 6;
const _bitness = 1 << _logBitness;
const _capacity = 4096;
// Don't bother to replenish the buffer while
// this number of bytes is available.
const _safeguard = 36;
const _waterline = _capacity - _safeguard;
// After encountering the end of the input stream, this amount
// of zero bytes will be appended.
const _slack = 64;
const _bufferSize = _capacity + _slack;

const _byteness = _bitness ~/ 8;
const _logHalfSize = _logBitness - 4;
const _halfBitness = _bitness ~/ 2;
const _halfSize = _byteness ~/ 2;
const _halvesCapacity = _capacity ~/ _halfSize;
const _halfBufferSize = _bufferSize ~/ _halfSize;
const _halfWaterline = _waterline ~/ _halfSize;

int _calculateDistanceAlphabetSize(
  int npostfix,
  int ndirect,
  int maxndistbits,
) {
  return 16 + ndirect + 2 * (maxndistbits << npostfix);
}

int _calculateDistanceAlphabetLimit(
  int maxDistance,
  int npostfix,
  int ndirect,
) {
  if (maxDistance < ndirect + (2 << npostfix)) {
    throw const BrotliException('maxDistance is too small');
  }

  final offset = ((maxDistance - ndirect) >> npostfix) + 4;
  final ndistbits = _log2floor(offset) - 1;
  final group = ((ndistbits - 1) << 1) | ((offset >> ndistbits) & 1);

  return ((group - 1) << npostfix) + (1 << npostfix) + ndirect + 16;
}

int _decodeWindowBits(s) {
  final largeWindowEnabled = s.isLargeWindow;

  s.isLargeWindow = 0;

  _fillBitWindow(s);

  if (_readFewBits(s, 1) == 0) {
    return 16;
  }

  var n = _readFewBits(s, 3);

  if (n != 0) {
    return 17 + n;
  }

  n = _readFewBits(s, 3);

  if (n != 0) {
    if (n == 1) {
      if (largeWindowEnabled == 0) {
        return -1;
      }

      s.isLargeWindow = 1;

      if (_readFewBits(s, 1) == 1) {
        return -1;
      }

      n = _readFewBits(s, 6);

      if (n < 10 || n > 30) {
        return -1;
      }

      return n;
    } else {
      return 8 + n;
    }
  }

  return 17;
}

void _initState(
  State s,
  InputStream input,
) {
  if (s.runningState != 0) {
    throw const BrotliException('State MUST be uninitialized');
  }

  s.blockTrees = createInt32List(3091);
  s.blockTrees[0] = 7;
  s.distRbIdx = 3;
  final maxDistanceAlphabetLimit =
      _calculateDistanceAlphabetLimit(0x7FFFFFFC, 3, 15 << 3);
  s.distExtraBits = createInt8List(maxDistanceAlphabetLimit);
  s.distOffset = createInt32List(maxDistanceAlphabetLimit);
  s.input = input;

  _initBitReader(s);

  s.runningState = 1;
}

void _close(s) {
  if (s.runningState == 0) {
    throw const BrotliException('State must be initialized');
  }

  if (s.runningState == 11) {
    return;
  }

  s.runningState = 11;

  if (s.input != null) {
    s.input = null;
  }
}

int _decodeVarLenUnsignedByte(State s) {
  _fillBitWindow(s);

  if (_readFewBits(s, 1) != 0) {
    final n = _readFewBits(s, 3);

    if (n == 0) {
      return 1;
    } else {
      return _readFewBits(s, n) + (1 << n);
    }
  }

  return 0;
}

void _decodeMetaBlockLength(State s) {
  _fillBitWindow(s);

  s.inputEnd = _readFewBits(s, 1);
  s.metaBlockLength = 0;
  s.isUncompressed = 0;
  s.isMetadata = 0;

  if ((s.inputEnd != 0) && _readFewBits(s, 1) != 0) {
    return;
  }

  final sizeNibbles = _readFewBits(s, 2) + 4;

  if (sizeNibbles == 7) {
    s.isMetadata = 1;

    if (_readFewBits(s, 1) != 0) {
      throw const BrotliException('Corrupted reserved bit');
    }

    final sizeBytes = _readFewBits(s, 2);

    if (sizeBytes == 0) {
      return;
    }

    for (var i = 0; i < sizeBytes; i++) {
      _fillBitWindow(s);

      final bits = _readFewBits(s, 8);

      if (bits == 0 && i + 1 == sizeBytes && sizeBytes > 1) {
        throw const BrotliException('Exuberant nibble');
      }

      s.metaBlockLength |= bits << (i * 8);
    }
  } else {
    for (var i = 0; i < sizeNibbles; i++) {
      _fillBitWindow(s);

      final bits = _readFewBits(s, 4);

      if (bits == 0 && i + 1 == sizeNibbles && sizeNibbles > 4) {
        throw const BrotliException('Exuberant nibble');
      }
      s.metaBlockLength |= bits << (i * 4);
    }
  }

  s.metaBlockLength++;

  if (s.inputEnd == 0) {
    s.isUncompressed = _readFewBits(s, 1);
  }
}

int _readSymbol(
  List<int> tableGroup,
  int tableIdx,
  State s,
) {
  var offset = tableGroup[tableIdx];
  final val = _peekBits(s);
  offset += val & 0xFF;
  final bits = tableGroup[offset] >> 16;
  final sym = tableGroup[offset] & 0xFFFF;

  if (bits <= 8) {
    s.bitOffset += bits;
    return sym;
  }

  offset += sym;

  final mask = (1 << bits) - 1;
  offset += (val & mask) >>> 8;
  s.bitOffset += (tableGroup[offset] >> 16) + 8;

  return tableGroup[offset] & 0xFFFF;
}

int _readBlockLength(
  List<int> tableGroup,
  int tableIdx,
  State s,
) {
  _fillBitWindow(s);

  final code = _readSymbol(tableGroup, tableIdx, s);
  final n = _blockLengthNBits[code];

  _fillBitWindow(s);

  return _blockLengthOffset[code] +
      ((n <= 16) ? _readFewBits(s, n) : _readManyBits(s, n));
}

void _moveToFront(
  List<int> v,
  int index,
) {
  final value = v[index];

  for (; index > 0; index--) {
    v[index] = v[index - 1];
  }

  v[0] = value;
}

void _inverseMoveToFrontTransform(
  List<int> v,
  int length,
) {
  final mtf = createInt32List(256);

  for (var i = 0; i < 256; i++) {
    mtf[i] = i;
  }

  for (var i = 0; i < length; i++) {
    final index = v[i] & 0xFF;

    v[i] = mtf[index];

    if (index != 0) {
      _moveToFront(mtf, index);
    }
  }
}

void _readHuffmanCodeLengths(
  List<int> codeLengthCodeLengths,
  int numSymbols,
  List<int> codeLengths,
  State s,
) {
  var symbol = 0;
  var prevCodeLen = 8;
  var repeat = 0;
  var repeatCodeLen = 0;
  var space = 32768;
  final table = createInt32List(32 + 1);
  final tableIdx = table.length - 1;

  _buildHuffmanTable(table, tableIdx, 5, codeLengthCodeLengths, 18);

  while (symbol < numSymbols && space > 0) {
    _readMoreInput(s);
    _fillBitWindow(s);

    final p = _peekBits(s) & 31;

    s.bitOffset += table[p] >> 16;
    final codeLen = table[p] & 0xFFFF;

    if (codeLen < 16) {
      repeat = 0;

      codeLengths[symbol++] = codeLen;

      if (codeLen != 0) {
        prevCodeLen = codeLen;
        space -= 32768 >> codeLen;
      }
    } else {
      final extraBits = codeLen - 14;
      var newLen = 0;

      if (codeLen == 16) {
        newLen = prevCodeLen;
      }

      if (repeatCodeLen != newLen) {
        repeat = 0;
        repeatCodeLen = newLen;
      }

      final oldRepeat = repeat;

      if (repeat > 0) {
        repeat -= 2;
        repeat <<= extraBits;
      }

      _fillBitWindow(s);

      repeat += _readFewBits(s, extraBits) + 3;
      final repeatDelta = repeat - oldRepeat;

      if (symbol + repeatDelta > numSymbols) {
        throw const BrotliException('symbol + repeatDelta > numSymbols');
      }

      for (var i = 0; i < repeatDelta; i++) {
        codeLengths[symbol++] = repeatCodeLen;
      }

      if (repeatCodeLen != 0) {
        space -= repeatDelta << (15 - repeatCodeLen);
      }
    }
  }

  if (space != 0) {
    throw const BrotliException('Unused space');
  }

  codeLengths.fillRange(symbol, numSymbols, 0);
}

void _checkDupes(
  List<int> symbols,
  int length,
) {
  for (var i = 0; i < length - 1; i++) {
    for (var j = i + 1; j < length; j++) {
      if (symbols[i] == symbols[j]) {
        throw const BrotliException('Duplicate simple Huffman code symbol');
      }
    }
  }
}

int _readSimpleHuffmanCode(
  int alphabetSizeMax,
  int alphabetSizeLimit,
  List<int> tableGroup,
  int tableIdx,
  State s,
) {
  final codeLengths = createInt32List(alphabetSizeLimit);
  final symbols = createInt32List(4);
  final maxBits = 1 + _log2floor(alphabetSizeMax - 1);
  final numSymbols = _readFewBits(s, 2) + 1;

  for (var i = 0; i < numSymbols; i++) {
    _fillBitWindow(s);

    final symbol = _readFewBits(s, maxBits);

    if (symbol >= alphabetSizeLimit) {
      throw const BrotliException("Can't readHuffmanCode");
    }

    symbols[i] = symbol;
  }

  _checkDupes(symbols, numSymbols);

  var histogramId = numSymbols;

  if (numSymbols == 4) {
    histogramId += _readFewBits(s, 1);
  }

  switch (histogramId) {
    case 1:
      codeLengths[symbols[0]] = 1;
      break;
    case 2:
      codeLengths[symbols[0]] = 1;
      codeLengths[symbols[1]] = 1;
      break;
    case 3:
      codeLengths[symbols[0]] = 1;
      codeLengths[symbols[1]] = 2;
      codeLengths[symbols[2]] = 2;
      break;
    case 4:
      codeLengths[symbols[0]] = 2;
      codeLengths[symbols[1]] = 2;
      codeLengths[symbols[2]] = 2;
      codeLengths[symbols[3]] = 2;
      break;
    case 5:
      codeLengths[symbols[0]] = 1;
      codeLengths[symbols[1]] = 2;
      codeLengths[symbols[2]] = 3;
      codeLengths[symbols[3]] = 3;
      break;
    default:
      break;
  }

  return _buildHuffmanTable(
    tableGroup,
    tableIdx,
    8,
    codeLengths,
    alphabetSizeLimit,
  );
}

int _readComplexHuffmanCode(
  int alphabetSizeLimit,
  int skip,
  List<int> tableGroup,
  int tableIdx,
  State s,
) {
  final codeLengths = createInt32List(alphabetSizeLimit);
  final codeLengthCodeLengths = createInt32List(18);
  var space = 32;
  var numCodes = 0;

  for (var i = skip; i < 18 && space > 0; i++) {
    final codeLenIdx = _codeLengthCodeOrder[i];

    _fillBitWindow(s);

    final p = _peekBits(s) & 15;
    s.bitOffset += _fixedTable[p] >> 16;
    final v = _fixedTable[p] & 0xFFFF;

    codeLengthCodeLengths[codeLenIdx] = v;

    if (v != 0) {
      space -= 32 >> v;
      numCodes++;
    }
  }

  if (space != 0 && numCodes != 1) {
    throw const BrotliException('Corrupted Huffman code histogram');
  }

  _readHuffmanCodeLengths(
    codeLengthCodeLengths,
    alphabetSizeLimit,
    codeLengths,
    s,
  );

  return _buildHuffmanTable(
    tableGroup,
    tableIdx,
    8,
    codeLengths,
    alphabetSizeLimit,
  );
}

int _readHuffmanCode(
  int alphabetSizeMax,
  int alphabetSizeLimit,
  List<int> tableGroup,
  int tableIdx,
  State s,
) {
  _readMoreInput(s);

  _fillBitWindow(s);

  final simpleCodeOrSkip = _readFewBits(s, 2);

  if (simpleCodeOrSkip == 1) {
    return _readSimpleHuffmanCode(
      alphabetSizeMax,
      alphabetSizeLimit,
      tableGroup,
      tableIdx,
      s,
    );
  } else {
    return _readComplexHuffmanCode(
      alphabetSizeLimit,
      simpleCodeOrSkip,
      tableGroup,
      tableIdx,
      s,
    );
  }
}

int _decodeContextMap(
  int contextMapSize,
  List<int> contextMap,
  State s,
) {
  _readMoreInput(s);

  final numTrees = _decodeVarLenUnsignedByte(s) + 1;

  if (numTrees == 1) {
    contextMap.fillRange(0, contextMapSize, 0);
    return numTrees;
  }

  _fillBitWindow(s);

  final useRleForZeros = _readFewBits(s, 1);
  var maxRunLengthPrefix = 0;

  if (useRleForZeros != 0) {
    maxRunLengthPrefix = _readFewBits(s, 4) + 1;
  }

  final alphabetSize = numTrees + maxRunLengthPrefix;
  final tableSize = _maxHuffmanTableSize[(alphabetSize + 31) >> 5];
  final table = createInt32List(tableSize + 1);
  final tableIdx = table.length - 1;

  _readHuffmanCode(alphabetSize, alphabetSize, table, tableIdx, s);

  for (var i = 0; i < contextMapSize;) {
    _readMoreInput(s);

    _fillBitWindow(s);

    final code = _readSymbol(table, tableIdx, s);

    if (code == 0) {
      contextMap[i] = 0;
      i++;
    } else if (code <= maxRunLengthPrefix) {
      _fillBitWindow(s);

      var reps = (1 << code) + _readFewBits(s, code);

      while (reps != 0) {
        if (i >= contextMapSize) {
          throw const BrotliException('Corrupted context map');
        }

        contextMap[i] = 0;
        i++;
        reps--;
      }
    } else {
      contextMap[i] = code - maxRunLengthPrefix;
      i++;
    }
  }

  _fillBitWindow(s);

  if (_readFewBits(s, 1) == 1) {
    _inverseMoveToFrontTransform(contextMap, contextMapSize);
  }

  return numTrees;
}

int _decodeBlockTypeAndLength(
  State s,
  int treeType,
  int numBlockTypes,
) {
  final ringBuffers = s.rings;
  final offset = 4 + treeType * 2;

  _fillBitWindow(s);

  var blockType = _readSymbol(s.blockTrees, 2 * treeType, s);
  final result = _readBlockLength(s.blockTrees, 2 * treeType + 1, s);

  if (blockType == 1) {
    blockType = ringBuffers[offset + 1] + 1;
  } else if (blockType == 0) {
    blockType = ringBuffers[offset];
  } else {
    blockType -= 2;
  }

  if (blockType >= numBlockTypes) {
    blockType -= numBlockTypes;
  }

  ringBuffers[offset] = ringBuffers[offset + 1];
  ringBuffers[offset + 1] = blockType;

  return result;
}

void _decodeLiteralBlockSwitch(s) {
  s.literalBlockLength =
      _decodeBlockTypeAndLength(s, 0, s.numLiteralBlockTypes);
  final literalBlockType = s.rings[5];
  s.contextMapSlice = literalBlockType << 6;
  s.literalTreeIdx = s.contextMap[s.contextMapSlice] & 0xFF;
  final contextMode = s.contextModes[literalBlockType];
  s.contextLookupOffset1 = contextMode << 9;
  s.contextLookupOffset2 = s.contextLookupOffset1 + 256;
}

void _decodeCommandBlockSwitch(s) {
  s.commandBlockLength =
      _decodeBlockTypeAndLength(s, 1, s.numCommandBlockTypes);
  s.commandTreeIdx = s.rings[7];
}

void _decodeDistanceBlockSwitch(s) {
  s.distanceBlockLength =
      _decodeBlockTypeAndLength(s, 2, s.numDistanceBlockTypes);
  s.distContextMapSlice = s.rings[9] << 2;
}

void _maybeReallocateRingBuffer(State s) {
  var newSize = s.maxRingBufferSize;

  if (newSize > s.expectedTotalSize) {
    final minimalNewSize = s.expectedTotalSize;

    while ((newSize >> 1) > minimalNewSize) {
      newSize >>= 1;
    }

    if ((s.inputEnd == 0) && newSize < 16384 && s.maxRingBufferSize >= 16384) {
      newSize = 16384;
    }
  }

  if (newSize <= s.ringBufferSize) {
    return;
  }

  final ringBufferSizeWithSlack = newSize + 37;
  final newBuffer = createInt8List(ringBufferSizeWithSlack);

  if (s.ringBuffer.isNotEmpty) {
    newBuffer.setAll(0, s.ringBuffer.sublist(0, 0 + s.ringBufferSize));
  }

  s.ringBuffer = newBuffer;
  s.ringBufferSize = newSize;
}

void _readNextMetablockHeader(State s) {
  if (s.inputEnd != 0) {
    s.nextRunningState = 10;
    s.runningState = 12;
    return;
  }

  s.literalTreeGroup = createInt32List(0);
  s.commandTreeGroup = createInt32List(0);
  s.distanceTreeGroup = createInt32List(0);

  _readMoreInput(s);

  _decodeMetaBlockLength(s);

  if (s.metaBlockLength == 0 && s.isMetadata == 0) {
    return;
  }

  if (s.isUncompressed != 0 || s.isMetadata != 0) {
    _jumpToByteBoundary(s);
    s.runningState = s.isMetadata != 0 ? 5 : 6;
  } else {
    s.runningState = 3;
  }

  if (s.isMetadata != 0) {
    return;
  }

  s.expectedTotalSize += s.metaBlockLength;

  if (s.expectedTotalSize > 1 << 30) {
    s.expectedTotalSize = 1 << 30;
  }

  if (s.ringBufferSize < s.maxRingBufferSize) {
    _maybeReallocateRingBuffer(s);
  }
}

int _readMetablockPartition(
  State s,
  int treeType,
  int numBlockTypes,
) {
  var offset = s.blockTrees[2 * treeType];

  if (numBlockTypes <= 1) {
    s.blockTrees[2 * treeType + 1] = offset;
    s.blockTrees[2 * treeType + 2] = offset;
    return 1 << 28;
  }

  final blockTypeAlphabetSize = numBlockTypes + 2;

  offset += _readHuffmanCode(
    blockTypeAlphabetSize,
    blockTypeAlphabetSize,
    s.blockTrees,
    2 * treeType,
    s,
  );

  s.blockTrees[2 * treeType + 1] = offset;

  const blockLengthAlphabetSize = 26;

  offset += _readHuffmanCode(
    blockLengthAlphabetSize,
    blockLengthAlphabetSize,
    s.blockTrees,
    2 * treeType + 1,
    s,
  );

  s.blockTrees[2 * treeType + 2] = offset;

  return _readBlockLength(s.blockTrees, 2 * treeType + 1, s);
}

void _calculateDistanceLut(
  State s,
  int alphabetSizeLimit,
) {
  final distExtraBits = s.distExtraBits;
  final distOffset = s.distOffset;
  final npostfix = s.distancePostfixBits;
  final ndirect = s.numDirectDistanceCodes;
  final postfix = 1 << npostfix;
  var bits = 1;
  var half = 0;
  var i = 16;

  for (var j = 0; j < ndirect; j++) {
    distExtraBits[i] = 0;
    distOffset[i] = j + 1;
    i++;
  }

  while (i < alphabetSizeLimit) {
    final base = ndirect + ((((2 + half) << bits) - 4) << npostfix) + 1;

    for (var j = 0; j < postfix; j++) {
      distExtraBits[i] = bits;
      distOffset[i] = base + j;
      i++;
    }

    bits = bits + half;
    half = half ^ 1;
  }
}

void _readMetablockHuffmanCodesAndContextMaps(State s) {
  s.numLiteralBlockTypes = _decodeVarLenUnsignedByte(s) + 1;
  s.literalBlockLength = _readMetablockPartition(s, 0, s.numLiteralBlockTypes);
  s.numCommandBlockTypes = _decodeVarLenUnsignedByte(s) + 1;
  s.commandBlockLength = _readMetablockPartition(s, 1, s.numCommandBlockTypes);
  s.numDistanceBlockTypes = _decodeVarLenUnsignedByte(s) + 1;
  s.distanceBlockLength =
      _readMetablockPartition(s, 2, s.numDistanceBlockTypes);

  _readMoreInput(s);
  _fillBitWindow(s);

  s.distancePostfixBits = _readFewBits(s, 2);
  s.numDirectDistanceCodes = _readFewBits(s, 4) << s.distancePostfixBits;
  s.contextModes = createInt8List(s.numLiteralBlockTypes);

  for (var i = 0; i < s.numLiteralBlockTypes;) {
    final limit = min(i + 96, s.numLiteralBlockTypes);

    for (; i < limit; i++) {
      _fillBitWindow(s);
      s.contextModes[i] = _readFewBits(s, 2);
    }

    if (s.halfOffset > _halfWaterline) {
      _doReadMoreInput(s);
    }
  }

  s.contextMap = createInt8List(s.numLiteralBlockTypes << 6);

  final numLiteralTrees =
      _decodeContextMap(s.numLiteralBlockTypes << 6, s.contextMap, s);
  s.trivialLiteralContext = 1;

  for (var j = 0; j < s.numLiteralBlockTypes << 6; j++) {
    if (s.contextMap[j] != j >> 6) {
      s.trivialLiteralContext = 0;
      break;
    }
  }

  s.distContextMap = createInt8List(s.numDistanceBlockTypes << 2);
  final numDistTrees = _decodeContextMap(
    s.numDistanceBlockTypes << 2,
    s.distContextMap,
    s,
  );
  s.literalTreeGroup = _decodeHuffmanTreeGroup(256, 256, numLiteralTrees, s);
  s.commandTreeGroup = _decodeHuffmanTreeGroup(
    704,
    704,
    s.numCommandBlockTypes,
    s,
  );

  var distanceAlphabetSizeMax = _calculateDistanceAlphabetSize(
    s.distancePostfixBits,
    s.numDirectDistanceCodes,
    24,
  );

  var distanceAlphabetSizeLimit = distanceAlphabetSizeMax;

  if (s.isLargeWindow == 1) {
    distanceAlphabetSizeMax = _calculateDistanceAlphabetSize(
      s.distancePostfixBits,
      s.numDirectDistanceCodes,
      62,
    );
    distanceAlphabetSizeLimit = _calculateDistanceAlphabetLimit(
      0x7FFFFFFC,
      s.distancePostfixBits,
      s.numDirectDistanceCodes,
    );
  }

  s.distanceTreeGroup = _decodeHuffmanTreeGroup(
    distanceAlphabetSizeMax,
    distanceAlphabetSizeLimit,
    numDistTrees,
    s,
  );

  _calculateDistanceLut(s, distanceAlphabetSizeLimit);

  s.contextMapSlice = 0;
  s.distContextMapSlice = 0;
  s.contextLookupOffset1 = s.contextModes[0] * 512;
  s.contextLookupOffset2 = s.contextLookupOffset1 + 256;
  s.literalTreeIdx = 0;
  s.commandTreeIdx = 0;
  s.rings[4] = 1;
  s.rings[5] = 0;
  s.rings[6] = 1;
  s.rings[7] = 0;
  s.rings[8] = 1;
  s.rings[9] = 0;
}

void _copyUncompressedData(State s) {
  final ringBuffer = s.ringBuffer;

  if (s.metaBlockLength <= 0) {
    _reload(s);
    s.runningState = 2;
    return;
  }

  final chunkLength = min(s.ringBufferSize - s.pos, s.metaBlockLength);

  _copyBytes(s, ringBuffer, s.pos, chunkLength);

  s.metaBlockLength -= chunkLength;
  s.pos += chunkLength;

  if (s.pos == s.ringBufferSize) {
    s.nextRunningState = 6;
    s.runningState = 12;
    return;
  }

  _reload(s);

  s.runningState = 2;
}

int _writeRingBuffer(State s) {
  final toWrite = min(
    s.outputLength - s.outputUsed,
    s.ringBufferBytesReady - s.ringBufferBytesWritten,
  );

  if (toWrite != 0) {
    s.output.setAll(
      s.outputOffset + s.outputUsed,
      s.ringBuffer.sublist(
          s.ringBufferBytesWritten, s.ringBufferBytesWritten + toWrite),
    );
    s.outputUsed += toWrite;
    s.ringBufferBytesWritten += toWrite;
  }

  if (s.outputUsed < s.outputLength) {
    return 1;
  } else {
    return 0;
  }
}

List<int> _decodeHuffmanTreeGroup(
  int alphabetSizeMax,
  int alphabetSizeLimit,
  int n,
  State s,
) {
  final maxTableSize = _maxHuffmanTableSize[(alphabetSizeLimit + 31) >> 5];
  final group = createInt32List(n + n * maxTableSize);
  var next = n;

  for (var i = 0; i < n; i++) {
    group[i] = next;
    next += _readHuffmanCode(alphabetSizeMax, alphabetSizeLimit, group, i, s);
  }

  return group;
}

int _calculateFence(State s) {
  var result = s.ringBufferSize;

  if (s.isEager != 0) {
    result = min(
      result,
      s.ringBufferBytesWritten + s.outputLength - s.outputUsed,
    );
  }

  return result;
}

void _decompress(State s) {
  if (s.runningState == 0) {
    throw const BrotliException("Can't decompress until initialized");
  }

  if (s.runningState == 11) {
    throw const BrotliException("Can't decompress after close");
  }

  if (s.runningState == 1) {
    final windowBits = _decodeWindowBits(s);

    if (windowBits == -1) {
      throw const BrotliException("Invalid 'windowBits' code");
    }

    s.maxRingBufferSize = 1 << windowBits;
    s.maxBackwardDistance = s.maxRingBufferSize - 16;
    s.runningState = 2;
  }

  var fence = _calculateFence(s);
  var ringBufferMask = s.ringBufferSize - 1;
  var ringBuffer = s.ringBuffer;

  while (s.runningState != 10) {
    switch (s.runningState) {
      // BLOCK_START.
      case 2:
        if (s.metaBlockLength < 0) {
          throw const BrotliException('Invalid metablock length');
        }

        _readNextMetablockHeader(s);
        fence = _calculateFence(s);
        ringBufferMask = s.ringBufferSize - 1;
        ringBuffer = s.ringBuffer;
        continue;
      // COMPRESSED_BLOCK_START.
      case 3:
        _readMetablockHuffmanCodesAndContextMaps(s);
        s.runningState = 4;
        continue;
      // MAIN_LOOP.
      case 4:
        if (s.metaBlockLength <= 0) {
          s.runningState = 2;
          continue;
        }

        if (s.halfOffset > _halfWaterline) {
          _doReadMoreInput(s);
        }

        if (s.commandBlockLength == 0) {
          _decodeCommandBlockSwitch(s);
        }

        s.commandBlockLength--;

        _fillBitWindow(s);

        final cmdCode =
            _readSymbol(s.commandTreeGroup, s.commandTreeIdx, s) << 2;
        final insertAndCopyExtraBits = cmdLookup[cmdCode];
        final insertLengthOffset = cmdLookup[cmdCode + 1];
        final copyLengthOffset = cmdLookup[cmdCode + 2];

        s.distanceCode = cmdLookup[cmdCode + 3];

        _fillBitWindow(s);

        final insertLengthExtraBits = insertAndCopyExtraBits & 0xFF;
        s.insertLength =
            insertLengthOffset + _readBits(s, insertLengthExtraBits);

        _fillBitWindow(s);

        final copyLengthExtraBits = insertAndCopyExtraBits >> 8;
        s.copyLength = copyLengthOffset + _readBits(s, copyLengthExtraBits);

        s.j = 0;
        s.runningState = 7;

        continue;
      // INSERT_LOOP.
      case 7:
        if (s.trivialLiteralContext != 0) {
          while (s.j < s.insertLength) {
            _readMoreInput(s);

            if (s.literalBlockLength == 0) {
              _decodeLiteralBlockSwitch(s);
            }

            s.literalBlockLength--;

            _fillBitWindow(s);

            ringBuffer[s.pos] = _readSymbol(
              s.literalTreeGroup,
              s.literalTreeIdx,
              s,
            );

            s.pos++;
            s.j++;

            if (s.pos >= fence) {
              s.nextRunningState = 7;
              s.runningState = 12;
              break;
            }
          }
        } else {
          var prevByte1 = ringBuffer[(s.pos - 1) & ringBufferMask] & 0xFF;
          var prevByte2 = ringBuffer[(s.pos - 2) & ringBufferMask] & 0xFF;

          while (s.j < s.insertLength) {
            _readMoreInput(s);

            if (s.literalBlockLength == 0) {
              _decodeLiteralBlockSwitch(s);
            }

            final literalContext = lookup[s.contextLookupOffset1 + prevByte1] |
                lookup[s.contextLookupOffset2 + prevByte2];
            final literalTreeIdx =
                s.contextMap[s.contextMapSlice + literalContext] & 0xFF;

            s.literalBlockLength--;
            prevByte2 = prevByte1;

            _fillBitWindow(s);

            prevByte1 = _readSymbol(s.literalTreeGroup, literalTreeIdx, s);
            ringBuffer[s.pos] = prevByte1;
            s.pos++;
            s.j++;

            if (s.pos >= fence) {
              s.nextRunningState = 7;
              s.runningState = 12;
              break;
            }
          }
        }

        if (s.runningState != 7) {
          continue;
        }

        s.metaBlockLength -= s.insertLength;

        if (s.metaBlockLength <= 0) {
          s.runningState = 4;
          continue;
        }

        var distanceCode = s.distanceCode;

        if (distanceCode < 0) {
          s.distance = s.rings[s.distRbIdx];
        } else {
          _readMoreInput(s);

          if (s.distanceBlockLength == 0) {
            _decodeDistanceBlockSwitch(s);
          }

          s.distanceBlockLength--;

          _fillBitWindow(s);

          final distTreeIdx =
              s.distContextMap[s.distContextMapSlice + distanceCode] & 0xFF;
          distanceCode = _readSymbol(s.distanceTreeGroup, distTreeIdx, s);

          if (distanceCode < 16) {
            final index =
                (s.distRbIdx + _distanceShortCodeIndexOffset[distanceCode]) &
                    0x3;
            s.distance =
                s.rings[index] + _distanceShortCodeValueOffset[distanceCode];

            if (s.distance < 0) {
              throw const BrotliException('Negative distance');
            }
          } else {
            final extraBits = s.distExtraBits[distanceCode];
            int bits;

            if (s.bitOffset + extraBits <= _bitness) {
              bits = _readFewBits(s, extraBits);
            } else {
              _fillBitWindow(s);
              bits = _readBits(s, extraBits);
            }

            s.distance =
                s.distOffset[distanceCode] + (bits << s.distancePostfixBits);
          }
        }

        if (s.maxDistance != s.maxBackwardDistance &&
            s.pos < s.maxBackwardDistance) {
          s.maxDistance = s.pos;
        } else {
          s.maxDistance = s.maxBackwardDistance;
        }

        if (s.distance > s.maxDistance) {
          s.runningState = 9;
          continue;
        }

        if (distanceCode > 0) {
          s.distRbIdx = (s.distRbIdx + 1) & 0x3;
          s.rings[s.distRbIdx] = s.distance;
        }

        if (s.copyLength > s.metaBlockLength) {
          throw const BrotliException('Invalid backward reference');
        }

        s.j = 0;
        s.runningState = 8;
        continue;
      // COPY_LOOP.
      case 8:
        var src = (s.pos - s.distance) & ringBufferMask;
        var dst = s.pos;
        final copyLength = s.copyLength - s.j;
        final srcEnd = src + copyLength;
        final dstEnd = dst + copyLength;

        if ((srcEnd < ringBufferMask) && (dstEnd < ringBufferMask)) {
          if (copyLength < 12 || (srcEnd > dst && dstEnd > src)) {
            for (var k = 0; k < copyLength; k += 4) {
              ringBuffer[dst++] = ringBuffer[src++];
              ringBuffer[dst++] = ringBuffer[src++];
              ringBuffer[dst++] = ringBuffer[src++];
              ringBuffer[dst++] = ringBuffer[src++];
            }
          } else {
            ringBuffer.copyWithin(dst, src, srcEnd);
          }

          s.j += copyLength;
          s.metaBlockLength -= copyLength;
          s.pos += copyLength;
        } else {
          for (; s.j < s.copyLength;) {
            ringBuffer[s.pos] =
                ringBuffer[(s.pos - s.distance) & ringBufferMask];
            s.metaBlockLength--;
            s.pos++;
            s.j++;

            if (s.pos >= fence) {
              s.nextRunningState = 8;
              s.runningState = 12;
              break;
            }
          }
        }

        if (s.runningState == 8) {
          s.runningState = 4;
        }

        continue;
      // COPY_FROM_COMPOUND_DICTIONARY.
      case 9:
        _doUseDictionary(s, fence);
        continue;
      // USE_DICTIONARY.
      case 14:
        s.pos += _copyFromCompoundDictionary(s, fence);

        if (s.pos >= fence) {
          s.nextRunningState = 14;
          s.runningState = 12;
          return;
        }

        s.runningState = 4;

        continue;
      // READ_METADATA.
      case 5:
        while (s.metaBlockLength > 0) {
          _readMoreInput(s);

          _fillBitWindow(s);

          _readFewBits(s, 8);
          s.metaBlockLength--;
        }

        s.runningState = 2;
        continue;
      // COPY_UNCOMPRESSED.
      case 6:
        _copyUncompressedData(s);
        continue;
      // INIT_WRITE.
      case 12:
        s.ringBufferBytesReady = min(s.pos, s.ringBufferSize);
        s.runningState = 13;
        continue;
      // WRITE.
      case 13:
        if (_writeRingBuffer(s) == 0) {
          return;
        }

        if (s.pos >= s.maxBackwardDistance) {
          s.maxDistance = s.maxBackwardDistance;
        }

        if (s.pos >= s.ringBufferSize) {
          if (s.pos > s.ringBufferSize) {
            ringBuffer.copyWithin(0, s.ringBufferSize, s.pos);
          }

          s.pos &= ringBufferMask;
          s.ringBufferBytesWritten = 0;
        }

        s.runningState = s.nextRunningState;
        continue;
      default:
        throw BrotliException('Unexpected state: ${s.runningState}');
    }
  }

  if (s.runningState == 10) {
    if (s.metaBlockLength < 0) {
      throw const BrotliException('Invalid metablock length');
    }

    _jumpToByteBoundary(s);
    _checkHealth(s, 1);
  }
}

void _attachDictionaryChunk(State s, List<int> data) {
  if (s.runningState != 0) {
    throw const BrotliException("State must be freshly initialized");
  }

  if (s.cdNumChunks == 0) {
    s.cdChunks = List.generate(16, (index) => []);
    s.cdChunkOffsets = createInt32List(16);
    s.cdBlockBits = -1;
  }

  if (s.cdNumChunks == 15) {
    throw const BrotliException("Too many dictionary chunks");
  }

  s.cdChunks[s.cdNumChunks] = data;
  s.cdNumChunks++;
  s.cdTotalSize += data.length;
  s.cdChunkOffsets[s.cdNumChunks] = s.cdTotalSize;
}

void _doUseDictionary(State s, int fence) {
  final data = dictionaryData;

  if (s.distance > 0x7FFFFFFC) {
    throw const BrotliException("Invalid backward reference");
  }

  final address = s.distance - s.maxDistance - 1 - s.cdTotalSize;

  if (address < 0) {
    _initializeCompoundDictionaryCopy(s, -address - 1, s.copyLength);
    s.runningState = 14;
  } else {
    if (s.distance > 0x7FFFFFFC) {
      throw const BrotliException('Invalid backward reference');
    }

    final wordLength = s.copyLength;

    if (wordLength > 31) {
      throw BrotliException("Invalid backward reference");
    }

    final shift = dictionarySizeBits[wordLength];

    if (shift == 0) {
      throw const BrotliException("Invalid backward reference");
    }

    var offset = dictionaryOffsets[s.copyLength];
    final mask = (1 << shift) - 1;
    final wordIdx = address & mask;
    final transformIdx = address >>> shift;

    offset += wordIdx * s.copyLength;

    if (transformIdx >= rfcTransforms.numTransforms) {
      throw const BrotliException("Invalid backward reference");
    }

    final len = _transformDictionaryWord(
      s.ringBuffer,
      s.pos,
      data,
      offset,
      wordLength,
      rfcTransforms,
      transformIdx,
    );

    s.pos += len;
    s.metaBlockLength -= len;

    if (s.pos >= fence) {
      s.nextRunningState = 4;
      s.runningState = 12;
    } else {
      s.runningState = 4;
    }
  }
}

void _initializeCompoundDictionary(State s) {
  s.cdBlockMap = createInt8List(1 << 8);
  var blockBits = 8;
  // If this function is executed, then s.cdTotalSize > 0.
  while (((s.cdTotalSize - 1) >>> blockBits) != 0) {
    blockBits++;
  }

  blockBits -= 8;

  s.cdBlockBits = blockBits;
  var cursor = 0;
  var index = 0;

  while (cursor < s.cdTotalSize) {
    while (s.cdChunkOffsets[index + 1] < cursor) {
      index++;
    }

    s.cdBlockMap[cursor >>> blockBits] = index;
    cursor += 1 << blockBits;
  }
}

void _initializeCompoundDictionaryCopy(State s, int address, int length) {
  if (s.cdBlockBits == -1) {
    _initializeCompoundDictionary(s);
  }

  var index = s.cdBlockMap[address >>> s.cdBlockBits];

  while (address >= s.cdChunkOffsets[index + 1]) {
    index++;
  }

  if (s.cdTotalSize > address + length) {
    throw const BrotliException("Invalid backward reference");
  }

  // Update the recent distances cache.
  s.distRbIdx = (s.distRbIdx + 1) & 0x3;
  s.rings[s.distRbIdx] = s.distance;
  s.metaBlockLength -= length;
  s.cdBrIndex = index;
  s.cdBrOffset = address - s.cdChunkOffsets[index];
  s.cdBrLength = length;
  s.cdBrCopied = 0;
}

int _copyFromCompoundDictionary(State s, int fence) {
  var pos = s.pos;
  var origPos = pos;

  while (s.cdBrLength != s.cdBrCopied) {
    final space = fence - pos;

    final chunkLength =
        s.cdChunkOffsets[s.cdBrIndex + 1] - s.cdChunkOffsets[s.cdBrIndex];
    final remChunkLength = chunkLength - s.cdBrOffset;
    var length = s.cdBrLength - s.cdBrCopied;

    if (length > remChunkLength) {
      length = remChunkLength;
    }

    if (length > space) {
      length = space;
    }

    for (var i = 0; i < length; i++, pos++, s.cdBrOffset++, s.cdBrCopied++) {
      s.ringBuffer[s.cdBrOffset] = s.cdChunks[s.cdBrIndex][pos];
    }

    if (length == remChunkLength) {
      s.cdBrIndex++;
      s.cdBrOffset = 0;
    }

    if (pos >= fence) {
      break;
    }
  }
  return pos - origPos;
}

int _transformDictionaryWord(
  List<int> dst,
  int dstOffset,
  List<int> src,
  int srcOffset,
  int len,
  Transforms transforms,
  int transformIndex,
) {
  var offset = dstOffset;
  final triplets = transforms.triplets;
  final prefixSuffixStorage = transforms.prefixSuffixStorage;
  final prefixSuffixHeads = transforms.prefixSuffixHeads;
  final transformOffset = 3 * transformIndex;
  final prefixIdx = triplets[transformOffset];
  final transformType = triplets[transformOffset + 1];
  final suffixIdx = triplets[transformOffset + 2];
  var prefix = prefixSuffixHeads[prefixIdx];
  final prefixEnd = prefixSuffixHeads[prefixIdx + 1];
  var suffix = prefixSuffixHeads[suffixIdx];
  final suffixEnd = prefixSuffixHeads[suffixIdx + 1];
  var omitFirst = transformType - 11;
  var omitLast = transformType - 0;

  if (omitFirst < 1 || omitFirst > 9) {
    omitFirst = 0;
  }

  if (omitLast < 1 || omitLast > 9) {
    omitLast = 0;
  }

  while (prefix != prefixEnd) {
    dst[offset++] = prefixSuffixStorage[prefix++];
  }

  if (omitFirst > len) {
    omitFirst = len;
  }

  srcOffset += omitFirst;
  len -= omitFirst;
  len -= omitLast;

  var i = len;

  while (i > 0) {
    dst[offset++] = src[srcOffset++];
    i--;
  }

  if (transformType == 10 || transformType == 11) {
    var uppercaseOffset = offset - len;

    if (transformType == 10) {
      len = 1;
    }

    while (len > 0) {
      final c0 = dst[uppercaseOffset] & 0xFF;

      if (c0 < 0xC0) {
        if (c0 >= 97 && c0 <= 122) {
          dst[uppercaseOffset] ^= 32;
        }
        uppercaseOffset += 1;
        len -= 1;
      } else if (c0 < 0xE0) {
        dst[uppercaseOffset + 1] ^= 32;
        uppercaseOffset += 2;
        len -= 2;
      } else {
        dst[uppercaseOffset + 2] ^= 5;
        uppercaseOffset += 3;
        len -= 3;
      }
    }
  } else if (transformType == 21 || transformType == 22) {
    var shiftOffset = offset - len;
    final param = transforms.params[transformIndex];
    var scalar = (param & 0x7FFF) + (0x1000000 - (param & 0x8000));

    while (len > 0) {
      var step = 1;
      final c0 = dst[shiftOffset] & 0xFF;

      if (c0 < 0x80) {
        scalar += c0;
        dst[shiftOffset] = scalar & 0x7F;
      } else if (c0 < 0xC0) {
      } else if (c0 < 0xE0) {
        if (len >= 2) {
          final c1 = dst[shiftOffset + 1];

          scalar += (c1 & 0x3F) | ((c0 & 0x1F) << 6);
          dst[shiftOffset] = 0xC0 | ((scalar >> 6) & 0x1F);
          dst[shiftOffset + 1] = (c1 & 0xC0) | (scalar & 0x3F);

          step = 2;
        } else {
          step = len;
        }
      } else if (c0 < 0xF0) {
        if (len >= 3) {
          final c1 = dst[shiftOffset + 1];
          final c2 = dst[shiftOffset + 2];

          scalar += (c2 & 0x3F) | ((c1 & 0x3F) << 6) | ((c0 & 0x0F) << 12);

          dst[shiftOffset] = 0xE0 | ((scalar >> 12) & 0x0F);
          dst[shiftOffset + 1] = (c1 & 0xC0) | ((scalar >> 6) & 0x3F);
          dst[shiftOffset + 2] = (c2 & 0xC0) | (scalar & 0x3F);

          step = 3;
        } else {
          step = len;
        }
      } else if (c0 < 0xF8) {
        if (len >= 4) {
          final c1 = dst[shiftOffset + 1];
          final c2 = dst[shiftOffset + 2];
          final c3 = dst[shiftOffset + 3];

          scalar += (c3 & 0x3F) |
              ((c2 & 0x3F) << 6) |
              ((c1 & 0x3F) << 12) |
              ((c0 & 0x07) << 18);

          dst[shiftOffset] = 0xF0 | ((scalar >> 18) & 0x07);
          dst[shiftOffset + 1] = (c1 & 0xC0) | ((scalar >> 12) & 0x3F);
          dst[shiftOffset + 2] = (c2 & 0xC0) | ((scalar >> 6) & 0x3F);
          dst[shiftOffset + 3] = (c3 & 0xC0) | (scalar & 0x3F);

          step = 4;
        } else {
          step = len;
        }
      }

      shiftOffset += step;
      len -= step;

      if (transformType == 21) {
        len = 0;
      }
    }
  }

  while (suffix != suffixEnd) {
    dst[offset++] = prefixSuffixStorage[suffix++];
  }

  return offset - dstOffset;
}

int _getNextKey(
  int key,
  int len,
) {
  var step = 1 << (len - 1);

  while ((key & step) != 0) {
    step >>= 1;
  }

  return (key & (step - 1)) + step;
}

void _replicateValue(
  List<int> table,
  int offset,
  int step,
  int end,
  int item,
) {
  do {
    end -= step;
    table[offset + end] = item;
  } while (end > 0);
}

int _nextTableBitSize(
  List<int> count,
  int len,
  int rootBits,
) {
  var left = 1 << (len - rootBits);

  while (len < 15) {
    left -= count[len];
    if (left <= 0) {
      break;
    }
    len++;
    left <<= 1;
  }

  return len - rootBits;
}

int _buildHuffmanTable(
  List<int> tableGroup,
  int tableIdx,
  int rootBits,
  List<int> codeLengths,
  int codeLengthsSize,
) {
  final tableOffset = tableGroup[tableIdx];
  final sorted = createInt32List(codeLengthsSize);
  final count = createInt32List(16);
  final offset = createInt32List(16);

  for (var symbol = 0; symbol < codeLengthsSize; symbol++) {
    count[codeLengths[symbol]]++;
  }

  offset[1] = 0;

  for (var len = 1; len < 15; len++) {
    offset[len + 1] = offset[len] + count[len];
  }

  for (var symbol = 0; symbol < codeLengthsSize; symbol++) {
    if (codeLengths[symbol] != 0) {
      sorted[offset[codeLengths[symbol]]++] = symbol;
    }
  }

  var tableBits = rootBits;
  var tableSize = 1 << tableBits;
  var totalSize = tableSize;

  if (offset[15] == 1) {
    for (var key = 0; key < totalSize; key++) {
      tableGroup[tableOffset + key] = sorted[0];
    }
    return totalSize;
  }

  var key = 0;
  var symbol = 0;

  for (var len = 1, step = 2; len <= rootBits; len++, step <<= 1) {
    for (; count[len] > 0; count[len]--) {
      _replicateValue(tableGroup, tableOffset + key, step, tableSize,
          len << 16 | sorted[symbol++]);
      key = _getNextKey(key, len);
    }
  }

  final mask = totalSize - 1;
  var low = -1;
  var currentOffset = tableOffset;

  for (var len = rootBits + 1, step = 2; len <= 15; len++, step <<= 1) {
    for (; count[len] > 0; count[len]--) {
      if ((key & mask) != low) {
        currentOffset += tableSize;
        tableBits = _nextTableBitSize(count, len, rootBits);
        tableSize = 1 << tableBits;
        totalSize += tableSize;
        low = key & mask;
        tableGroup[tableOffset + low] =
            (tableBits + rootBits) << 16 | (currentOffset - tableOffset - low);
      }

      _replicateValue(
        tableGroup,
        currentOffset + (key >> rootBits),
        step,
        tableSize,
        (len - rootBits) << 16 | sorted[symbol++],
      );

      key = _getNextKey(key, len);
    }
  }
  return totalSize;
}

void _readMoreInput(State s) {
  if (s.halfOffset > _halfWaterline) {
    _doReadMoreInput(s);
  }
}

void _doReadMoreInput(State s) {
  if (s.endOfStreamReached != 0) {
    if (_halfAvailable(s) >= -2) {
      return;
    }

    throw const BrotliException('No more input');
  }

  final readOffset = s.halfOffset << _logHalfSize;
  var bytesInBuffer = _capacity - readOffset;
  // Move unused bytes to the head of the buffer.
  s.byteBuffer.copyWithin(0, readOffset, _capacity);
  s.halfOffset = 0;

  while (bytesInBuffer < _capacity) {
    final spaceLeft = _capacity - bytesInBuffer;
    final len = _readInput(s.input, s.byteBuffer, bytesInBuffer, spaceLeft);

    if (len <= 0) {
      s.endOfStreamReached = 1;
      s.tailBytes = bytesInBuffer;
      bytesInBuffer += _halfSize - 1;
      break;
    }

    bytesInBuffer += len;
  }

  _bytesToNibbles(s, bytesInBuffer);
}

void _checkHealth(
  State s,
  int endOfStream,
) {
  if (s.endOfStreamReached == 0) {
    return;
  }

  final byteOffset =
      (s.halfOffset << _logHalfSize) + ((s.bitOffset + 7) >> 3) - _byteness;

  if (byteOffset > s.tailBytes) {
    throw const BrotliException('Read after end');
  }

  if ((endOfStream != 0) && (byteOffset != s.tailBytes)) {
    throw const BrotliException('Unused bytes after end');
  }
}

int _readFewBits(State s, int n) {
  final val = _peekBits(s) & ((1 << n) - 1);
  s.bitOffset += n;
  return val;
}

void _doFillBitWindow(State s) {
  s.accumulator = (s.intBuffer[s.halfOffset++] << _halfBitness) |
      (s.accumulator >>> _halfBitness);
  s.bitOffset -= _halfBitness;
}

void _fillBitWindow(State s) {
  if (s.bitOffset >= _halfBitness) {
    _doFillBitWindow(s);
  }
}

int _peekBits(State s) {
  return (s.accumulator >>> s.bitOffset) & 0xFFFFFFFF;
}

int _readBits(State s, int n) {
  if (_halfBitness >= 24) {
    return _readFewBits(s, n);
  } else {
    return (n <= 16) ? _readFewBits(s, n) : _readManyBits(s, n);
  }
}

int _readManyBits(State s, int n) {
  final low = _readFewBits(s, 16);
  _fillBitWindow(s);
  return low | (_readFewBits(s, n - 16) << 16);
}

void _initBitReader(State s) {
  s.byteBuffer = createInt8List(_bufferSize);
  s.accumulator = 0;
  s.intBuffer = createInt32List(_halfBufferSize);
  s.bitOffset = _bitness;
  s.halfOffset = _halvesCapacity;
  s.endOfStreamReached = 0;
  _prepare(s);
}

void _prepare(State s) {
  _readMoreInput(s);
  _checkHealth(s, 0);
  _doFillBitWindow(s);
  _doFillBitWindow(s);
}

void _reload(State s) {
  if (s.bitOffset == _bitness) {
    _prepare(s);
  }
}

void _jumpToByteBoundary(State s) {
  final padding = (_bitness - s.bitOffset) & 7;

  if (padding != 0) {
    final paddingBits = _readFewBits(s, padding);

    if (paddingBits != 0) {
      throw const BrotliException('Corrupted padding bits');
    }
  }
}

int _halfAvailable(State s) {
  var limit = _halvesCapacity;

  if (s.endOfStreamReached != 0) {
    limit = (s.tailBytes + (_halfSize - 1)) >> _logHalfSize;
  }

  return limit - s.halfOffset;
}

void _copyBytes(
  State s,
  List<int> data,
  int offset,
  int length,
) {
  if ((s.bitOffset & 7) != 0) {
    throw const BrotliException('Unaligned copyBytes');
  }

  while ((s.bitOffset != _bitness) && (length != 0)) {
    data[offset++] = _peekBits(s);
    s.bitOffset += 8;
    length--;
  }

  if (length == 0) {
    return;
  }

  final copyNibbles = min(_halfAvailable(s), length >> _logHalfSize);

  if (copyNibbles > 0) {
    final readOffset = s.halfOffset << _logHalfSize;
    final delta = copyNibbles << _logHalfSize;

    for (var i = 0; i < delta; i++) {
      data[offset + i] = s.byteBuffer[readOffset + i];
    }

    offset += delta;
    length -= delta;

    s.halfOffset += copyNibbles;
  }

  if (length == 0) {
    return;
  }

  if (_halfAvailable(s) > 0) {
    _fillBitWindow(s);

    while (length != 0) {
      data[offset++] = _peekBits(s);
      s.bitOffset += 8;
      length--;
    }

    _checkHealth(s, 0);

    return;
  }

  while (length > 0) {
    final len = _readInput(s.input, data, offset, length);

    if (len == -1) {
      throw const BrotliException('Unexpected end of input');
    }

    offset += len;
    length -= len;
  }
}

void _bytesToNibbles(
  State s,
  int byteLen,
) {
  final byteBuffer = s.byteBuffer;
  final halfLen = byteLen >> _logHalfSize;
  final intBuffer = s.intBuffer;

  for (var i = 0; i < halfLen; i++) {
    intBuffer[i] = ((byteBuffer[i * 4] & 0xFF)) |
        ((byteBuffer[(i * 4) + 1] & 0xFF) << 8) |
        ((byteBuffer[(i * 4) + 2] & 0xFF) << 16) |
        ((byteBuffer[(i * 4) + 3] & 0xFF) << 24);
  }
}

int _readInput(
  InputStream? src,
  List<int> dst,
  int offset,
  int length,
) {
  if (src == null) {
    return -1;
  }

  final end = min(src.offset + length, src.data.length);
  final bytesRead = end - src.offset;

  dst.setAll(offset, src.data.sublist(src.offset, end));
  src.offset += bytesRead;

  return bytesRead;
}

/// An instance of the default implementation of the [BrotliCodec].
const brotli = BrotliCodec();

/// Parses the Brotli-encoded [data] and returns the decoded bytes.
///
/// Shorthand for `brotli.decode`. Useful if a local variable shadows the global
/// [brotli] constant.
List<int> brotliDecode(List<int> data) => brotli.decode(data);

/// The [BrotliCodec] encodes raw bytes to Brotli compressed bytes and
/// decodes Brotli compressed bytes to raw bytes.
class BrotliCodec extends Codec<List<int>, List<int>> {
  final List<int> compoundDictionary;

  /// Instantiates a new [BrotliCodec].
  const BrotliCodec({this.compoundDictionary = const []});

  /// Returns the [BrotliDecoder].
  @override
  Converter<List<int>, List<int>> get decoder => compoundDictionary.isEmpty
      ? const BrotliDecoder()
      : BrotliDecoder(compoundDictionary: compoundDictionary);

  @override
  Converter<List<int>, List<int>> get encoder =>
      throw UnsupportedError('Cannot encode with codec: Brotli');

  /// Decodes the [encoded] Brotli data to the corresponding string.
  ///
  /// Use [encoding] to specify the charset used by [encoded].
  String decodeToString(
    List<int> encoded, {
    Encoding? encoding,
  }) {
    final decoded = decoder.convert(encoded);
    return encoding != null
        ? encoding.decode(decoded)
        : String.fromCharCodes(decoded);
  }

  /// Decodes the Brotli-encoded [data] to the corresponding string.
  ///
  /// Use [encoding] to specify the charset used by [data].
  Future<String> decodeStream(
    Stream<List<int>> data, {
    Encoding encoding = utf8,
  }) {
    return decoder
        .bind(data)
        .transform(encoding.decoder)
        .fold<StringBuffer>(StringBuffer(), (b, string) => b..write(string))
        .then((buffer) => buffer.toString());
  }
}

List<int> _decode(
  List<int> data, [
  List<int>? compoundDictionary,
]) {
  var output = const <int>[];
  final sink =
      ByteConversionSink.withCallback((accumulated) => output = accumulated);
  _decodeToSink(data, sink, compoundDictionary);
  sink.close();
  return output;
}

void _decodeToSink(
  List<int> data,
  Sink<List<int>> sink, [
  List<int>? compoundDictionary,
]) {
  final s = State();
  final chunk = createInt8List(16384);
  var isLast = false;

  if (compoundDictionary != null && compoundDictionary.isNotEmpty) {
    _attachDictionaryChunk(s, compoundDictionary);
  }

  _initState(s, InputStream(data));

  while (!isLast) {
    s.outputOffset = 0;
    s.output = chunk;
    s.outputLength = chunk.length;
    s.outputUsed = 0;

    _decompress(s);

    final len = s.outputUsed;
    isLast = len < chunk.length;

    if (len < chunk.length) {
      sink.add(chunk.sublist(0, len));
    } else {
      sink.add(chunk);
    }
  }

  _close(s);
}

/// Converts Brotli compressed bytes to raw bytes.
class BrotliDecoder extends Converter<List<int>, List<int>> {
  final List<int> compoundDictionary;

  /// Instantiates a new [BrotliDecoder].
  const BrotliDecoder({this.compoundDictionary = const []});

  @override
  List<int> convert(List<int> input) {
    return _decode(input, compoundDictionary);
  }

  @override
  Sink<List<int>> startChunkedConversion(Sink<List<int>> sink) {
    return _BrotliSink(sink);
  }
}

class _BrotliSink implements Sink<List<int>> {
  final Sink<List<int>> sink;
  final _buffer = BytesBuilder(copy: false);

  _BrotliSink(this.sink);

  @override
  void add(List<int> data) {
    _buffer.add(data);
  }

  @override
  void close() {
    _decodeToSink(_buffer.takeBytes(), sink);
    sink.close();
  }
}
