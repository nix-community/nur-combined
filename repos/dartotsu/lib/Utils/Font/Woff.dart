/// WOFF / WOFF2 font decoder.
///
/// Converts WOFF1 and WOFF2 (Web Open Font Format) byte streams into raw
/// SFNT (TTF/OTF) bytes that can be consumed by font engines — most
/// importantly, Flutter's [FontLoader].
///
/// Pure Dart, no platform plugins, no FFI: WOFF1 uses `dart:io`'s zlib,
/// WOFF2 uses the `es_compression` Brotli decoder. The WOFF2
/// glyf/loca/hmtx transformations defined in the W3C spec are implemented
/// in Dart.
library;

import 'dart:io' show zlib;
import 'dart:math' as math;
import 'dart:typed_data';

import 'Brotli/Brotli.dart';

/// Result of a WOFF decode attempt.
enum WoffDecodeResult {
  /// Not a WOFF file — caller should use bytes as-is.
  notWoff,

  /// Successfully decoded WOFF1/WOFF2 → SFNT.
  ok,

  /// WOFF2 detected but decoding not supported (e.g. TTC collection).
  woff2Unsupported,

  /// WOFF1/WOFF2 file is malformed.
  malformed,
}

/// Inspects [bytes] and converts WOFF1/WOFF2 to SFNT if needed.
(WoffDecodeResult, Uint8List?) decodeFontIfWoff(Uint8List bytes) {
  if (bytes.length < 4) {
    return (WoffDecodeResult.notWoff, bytes);
  }

  final sig = (bytes[0] << 24) | (bytes[1] << 16) | (bytes[2] << 8) | bytes[3];

  if (sig == 0x774F4646) {
    // WOFF1
    final sfnt = _decodeWoff1(bytes);
    if (sfnt == null) {
      return (WoffDecodeResult.malformed, null);
    }
    return (WoffDecodeResult.ok, sfnt);
  }

  if (sig == 0x774F4632) {
    // WOFF2
    final sfnt = _decodeWoff2(bytes);
    if (sfnt == null) {
      return (WoffDecodeResult.malformed, null);
    }
    return (WoffDecodeResult.ok, sfnt);
  }

  return (WoffDecodeResult.notWoff, bytes);
}

// ---------------------------------------------------------------------------
// WOFF1 decoder
// ---------------------------------------------------------------------------

// WOFF header layout (44 bytes):
//   0  uint32 signature  = 0x774F4646
//   4  uint32 flavor     = sfVersion (copied to SFNT header)
//   8  uint32 length
//  12  uint16 numTables
//  14  uint16 reserved
//  16  uint32 totalSfntSize
//  20  uint16 majorVersion
//  22  uint16 minorVersion
//  24  uint32 metaOffset
//  28  uint32 metaLength
//  32  uint32 metaOrigLength
//  36  uint32 privOffset
//  40  uint32 privLength

Uint8List? _decodeWoff1(Uint8List woff) {
  if (woff.length < 44) return null;

  final hdr = woff.buffer.asByteData(woff.offsetInBytes, woff.lengthInBytes);

  final flavor = hdr.getUint32(4);
  final numTables = hdr.getUint16(12);

  if (woff.length < 44 + numTables * 20) return null;

  // ── 1. Read WOFF table directory ─────────────────────────────────────────
  final entries = List<_WoffEntry>.generate(numTables, (i) {
    final base = 44 + i * 20;
    return _WoffEntry(
      tag: hdr.getUint32(base),
      woffOffset: hdr.getUint32(base + 4),
      compLength: hdr.getUint32(base + 8),
      origLength: hdr.getUint32(base + 12),
      checkSum: hdr.getUint32(base + 16),
    );
  });

  // SFNT requires table directory sorted by tag.
  entries.sort((a, b) => a.tag.compareTo(b.tag));

  // ── 2. Decompress each table ──────────────────────────────────────────────
  final tableData = <Uint8List?>[];
  for (final e in entries) {
    final end = e.woffOffset + e.compLength;
    if (end > woff.length) return null;

    final compData = Uint8List.sublistView(woff, e.woffOffset, end);

    if (e.compLength < e.origLength) {
      // zlib-compressed (RFC 1950)
      Uint8List raw;
      try {
        raw = Uint8List.fromList(zlib.decode(compData));
      } catch (_) {
        return null;
      }
      if (raw.length != e.origLength) return null;
      tableData.add(raw);
    } else if (e.compLength == e.origLength) {
      tableData.add(compData);
    } else {
      return null; // compLength > origLength is invalid
    }
  }

  // ── 3. Calculate SFNT table offsets (4-byte aligned) ────────────────────
  final sfntHeaderSize = 12 + numTables * 16;
  final offsets = List<int>.filled(numTables, 0);
  var cursor = sfntHeaderSize;
  for (var i = 0; i < numTables; i++) {
    offsets[i] = cursor;
    cursor += (entries[i].origLength + 3) & ~3;
  }
  final totalSize = cursor;

  // ── 4. Write output ───────────────────────────────────────────────────────
  final out = Uint8List(totalSize);
  final w = out.buffer.asByteData();
  var pos = 0;

  // SFNT offset table
  w.setUint32(pos, flavor);
  pos += 4;
  w.setUint16(pos, numTables);
  pos += 2;
  final log2n = numTables > 0 ? math.log(numTables) ~/ math.log(2) : 0;
  final searchRange = (1 << log2n) * 16;
  final entrySelector = log2n;
  final rangeShift = numTables * 16 - searchRange;
  w.setUint16(pos, searchRange);
  pos += 2;
  w.setUint16(pos, entrySelector);
  pos += 2;
  w.setUint16(pos, rangeShift);
  pos += 2;

  // SFNT table directory
  for (var i = 0; i < numTables; i++) {
    final e = entries[i];
    w.setUint32(pos, e.tag);
    pos += 4;
    w.setUint32(pos, e.checkSum);
    pos += 4;
    w.setUint32(pos, offsets[i]);
    pos += 4;
    w.setUint32(pos, e.origLength);
    pos += 4;
  }

  // Table data
  for (var i = 0; i < numTables; i++) {
    final d = tableData[i]!;
    out.setRange(offsets[i], offsets[i] + d.length, d);
  }

  return out;
}

class _WoffEntry {
  const _WoffEntry({
    required this.tag,
    required this.woffOffset,
    required this.compLength,
    required this.origLength,
    required this.checkSum,
  });

  final int tag;
  final int woffOffset;
  final int compLength;
  final int origLength;
  final int checkSum;
}

// ---------------------------------------------------------------------------
// WOFF2 decoder
// ---------------------------------------------------------------------------

// Known WOFF2 tag table — 63 entries (index 0x3F = explicit tag follows).
const _kW2Tags = <int>[
  0x636D6170, // cmap   0
  0x68656164, // head   1
  0x68686561, // hhea   2
  0x686D7478, // hmtx   3
  0x6D617870, // maxp   4
  0x6E616D65, // name   5
  0x4F532F32, // OS/2   6
  0x706F7374, // post   7
  0x63767420, // cvt    8
  0x6670676D, // fpgm   9
  0x676C7966, // glyf  10
  0x6C6F6361, // loca  11
  0x70726570, // prep  12
  0x43464620, // CFF   13
  0x564F5247, // VORG  14
  0x45424454, // EBDT  15
  0x45424C43, // EBLC  16
  0x67617370, // gasp  17
  0x68646D78, // hdmx  18
  0x6B65726E, // kern  19
  0x4C545348, // LTSH  20
  0x50434C54, // PCLT  21
  0x56444D58, // VDMX  22
  0x76686561, // vhea  23
  0x766D7478, // vmtx  24
  0x42415345, // BASE  25
  0x47444546, // GDEF  26
  0x47504F53, // GPOS  27
  0x47535542, // GSUB  28
  0x45425343, // EBSC  29
  0x4A535446, // JSTF  30
  0x4D415448, // MATH  31
  0x43424454, // CBDT  32
  0x43424C43, // CBLC  33
  0x434F4C52, // COLR  34
  0x4350414C, // CPAL  35
  0x53564720, // SVG   36
  0x73626978, // sbix  37
  0x61636E74, // acnt  38
  0x61766172, // avar  39
  0x62646174, // bdat  40
  0x626C6F63, // bloc  41
  0x62736C6E, // bsln  42
  0x63766172, // cvar  43
  0x66647363, // fdsc  44
  0x66656174, // feat  45
  0x666D7478, // fmtx  46
  0x66766172, // fvar  47
  0x67766172, // gvar  48
  0x68737479, // hsty  49
  0x6A757374, // just  50
  0x6C636172, // lcar  51
  0x6D6F7274, // mort  52
  0x6D6F7278, // morx  53
  0x6F706264, // opbd  54
  0x70726F70, // prop  55
  0x7472616B, // trak  56
  0x5A617066, // Zapf  57
  0x53696C66, // Silf  58
  0x476C6174, // Glat  59
  0x476C6F63, // Gloc  60
  0x46656174, // Feat  61
  0x53696C6C, // Sill  62
];

class _W2Entry {
  _W2Entry({
    required this.tag,
    required this.isTransformed,
    required this.srcOffset,
    required this.srcLength,
    required this.dstLength,
  });
  final int tag;
  final bool isTransformed;
  final int srcOffset; // offset in Brotli-decompressed stream
  final int srcLength; // bytes in decompressed stream (0 for transformed loca)
  final int dstLength; // origLength (reconstructed size for non-transformed)
}

// ── Variable-length decoders ─────────────────────────────────────────────────

/// UIntBase128 decoder. Returns (ok, value, newPos).
(bool, int, int) _base128(Uint8List d, int pos) {
  int result = 0;
  for (int i = 0; i < 5; i++) {
    if (pos >= d.length) return (false, 0, pos);
    final code = d[pos++];
    if (i == 0 && code == 0x80) return (false, 0, pos); // leading zero invalid
    if ((result & 0xFE000000) != 0) return (false, 0, pos); // overflow
    result = (result << 7) | (code & 0x7F);
    if ((code & 0x80) == 0) return (true, result, pos);
  }
  return (false, 0, pos);
}

/// 255UInt16 decoder. Returns (ok, value, newPos).
(bool, int, int) _read255UShort(Uint8List d, int pos) {
  if (pos >= d.length) return (false, 0, pos);
  final code = d[pos++];
  if (code == 253) {
    // 2-byte uint16
    if (pos + 2 > d.length) return (false, 0, pos);
    final val = (d[pos] << 8) | d[pos + 1];
    return (true, val, pos + 2);
  } else if (code == 255) {
    if (pos >= d.length) return (false, 0, pos);
    return (true, d[pos] + 253, pos + 1);
  } else if (code == 254) {
    if (pos >= d.length) return (false, 0, pos);
    return (true, d[pos] + 506, pos + 1);
  } else {
    return (true, code, pos);
  }
}

// ── Checksum helpers ──────────────────────────────────────────────────────────

int _sfntChecksum(Uint8List d) {
  final bd = ByteData.sublistView(d);
  var sum = 0;
  final full = d.length ~/ 4;
  for (int i = 0; i < full; i++) {
    sum = (sum + bd.getUint32(i * 4)) & 0xFFFFFFFF;
  }
  final rem = d.length & 3;
  if (rem > 0) {
    int last = 0;
    for (int j = 0; j < rem; j++) {
      last |= d[full * 4 + j] << ((3 - j) * 8);
    }
    sum = (sum + last) & 0xFFFFFFFF;
  }
  return sum;
}

// ── Composite glyph size ──────────────────────────────────────────────────────

/// Returns the byte size of one composite glyph record in the composite stream
/// starting at [pos] in [d], and whether it has instructions.
/// Returns (-1, false) on parse error.
(int, bool) _sizeOfComposite(Uint8List d, int pos) {
  final start = pos;
  bool haveInstr = false;
  int compFlags = 0x20; // enter loop with FLAG_MORE_COMPONENTS set

  while ((compFlags & 0x20) != 0) {
    if (pos + 2 > d.length) return (-1, false);
    compFlags = (d[pos] << 8) | d[pos + 1];
    pos += 2;
    haveInstr =
        haveInstr || (compFlags & 0x100) != 0; // FLAG_WE_HAVE_INSTRUCTIONS
    int argSize = 2; // glyph index
    if ((compFlags & 0x01) != 0) {
      argSize += 4; // ARG_1_AND_2_ARE_WORDS
    } else {
      argSize += 2;
    }
    if ((compFlags & 0x08) != 0) {
      argSize += 2; // WE_HAVE_A_SCALE
    } else if ((compFlags & 0x40) != 0) {
      argSize += 4; // WE_HAVE_AN_X_AND_Y_SCALE
    } else if ((compFlags & 0x80) != 0) {
      argSize += 8; // WE_HAVE_A_TWO_BY_TWO
    }
    if (pos + argSize > d.length) return (-1, false);
    pos += argSize;
  }
  return (pos - start, haveInstr);
}

// ── TripletDecode ─────────────────────────────────────────────────────────────

int _withSign(int flag, int v) => (flag & 1) != 0 ? v : -v;

/// Decodes [nPoints] coordinate pairs from [flags] and [data] starting at
/// [dStart]. Appends results to [out]. Returns (ok, bytesConsumed).
(bool, int) _tripletDecode(
  Uint8List flags,
  Uint8List data,
  int dStart,
  int dLen,
  int nPoints,
  List<({int x, int y, bool onCurve})> out,
) {
  int x = 0, y = 0;
  int ti = 0;

  for (int i = 0; i < nPoints; i++) {
    if (i >= flags.length) return (false, 0);
    final rawFlag = flags[i];
    final onCurve = (rawFlag & 0x80) == 0;
    final flag = rawFlag & 0x7F;

    final int nBytes;
    if (flag < 84) {
      nBytes = 1;
    } else if (flag < 120) {
      nBytes = 2;
    } else if (flag < 124) {
      nBytes = 3;
    } else {
      nBytes = 4;
    }

    if (ti + nBytes > dLen) return (false, 0);

    final int dx, dy;
    if (flag < 10) {
      final d0 = data[dStart + ti];
      dx = 0;
      dy = _withSign(flag, ((flag & 14) << 7) + d0);
    } else if (flag < 20) {
      final d0 = data[dStart + ti];
      dx = _withSign(flag, (((flag - 10) & 14) << 7) + d0);
      dy = 0;
    } else if (flag < 84) {
      final f0 = flag - 20;
      final d1 = data[dStart + ti];
      dx = _withSign(flag, 1 + (f0 & 0x30) + (d1 >> 4));
      dy = _withSign(flag >> 1, 1 + ((f0 & 0x0C) << 2) + (d1 & 0x0F));
    } else if (flag < 120) {
      final f0 = flag - 84;
      final d0 = data[dStart + ti];
      final d1 = data[dStart + ti + 1];
      dx = _withSign(flag, 1 + ((f0 ~/ 12) << 8) + d0);
      dy = _withSign(flag >> 1, 1 + (((f0 % 12) >> 2) << 8) + d1);
    } else if (flag < 124) {
      final d0 = data[dStart + ti];
      final d1 = data[dStart + ti + 1];
      final d2 = data[dStart + ti + 2];
      dx = _withSign(flag, (d0 << 4) + (d1 >> 4));
      dy = _withSign(flag >> 1, ((d1 & 0x0F) << 8) + d2);
    } else {
      final d0 = data[dStart + ti];
      final d1 = data[dStart + ti + 1];
      final d2 = data[dStart + ti + 2];
      final d3 = data[dStart + ti + 3];
      dx = _withSign(flag, (d0 << 8) + d1);
      dy = _withSign(flag >> 1, (d2 << 8) + d3);
    }

    ti += nBytes;
    x += dx;
    y += dy;
    out.add((x: x, y: y, onCurve: onCurve));
  }
  return (true, ti);
}

// ── Build simple TTF glyph ────────────────────────────────────────────────────

Uint8List _buildSimpleGlyph(
  int nContours,
  int xMin,
  int yMin,
  int xMax,
  int yMax,
  List<int> nPointsVec,
  List<({int x, int y, bool onCurve})> points,
  Uint8List instrBytes,
  bool hasOverlapBit,
) {
  final instrLen = instrBytes.length;

  // ── header (10 bytes) ──────────────────────────────────────────────────────
  final header = ByteData(10);
  header.setInt16(0, nContours, Endian.big);
  header.setInt16(2, xMin, Endian.big);
  header.setInt16(4, yMin, Endian.big);
  header.setInt16(6, xMax, Endian.big);
  header.setInt16(8, yMax, Endian.big);

  // ── endPtsOfContours ──────────────────────────────────────────────────────
  final endPtsBuf = ByteData(nContours * 2);
  int endPt = -1;
  for (int j = 0; j < nContours; j++) {
    endPt += nPointsVec[j];
    endPtsBuf.setUint16(j * 2, endPt, Endian.big);
  }

  // ── instruction header ────────────────────────────────────────────────────
  final instrHdr = ByteData(2);
  instrHdr.setUint16(0, instrLen, Endian.big);

  // ── flags + x-coords + y-coords (StorePoints logic) ──────────────────────
  final flagBytes = <int>[];
  final xCoords = <int>[];
  final yCoords = <int>[];
  int lastX = 0, lastY = 0, lastFlag = -1, repeatCount = 0;

  for (int i = 0; i < points.length; i++) {
    final pt = points[i];
    int flag = pt.onCurve ? 0x01 : 0;
    if (hasOverlapBit && i == 0) flag |= 0x40;

    final dx = pt.x - lastX;
    final dy = pt.y - lastY;

    if (dx == 0) {
      flag |= 0x10;
    } else if (dx > -256 && dx < 256) {
      flag |= 0x02;
      if (dx > 0) flag |= 0x10;
      xCoords.add(dx.abs());
    } else {
      final u = dx & 0xFFFF;
      xCoords
        ..add((u >> 8) & 0xFF)
        ..add(u & 0xFF);
    }

    if (dy == 0) {
      flag |= 0x20;
    } else if (dy > -256 && dy < 256) {
      flag |= 0x04;
      if (dy > 0) flag |= 0x20;
      yCoords.add(dy.abs());
    } else {
      final u = dy & 0xFFFF;
      yCoords
        ..add((u >> 8) & 0xFF)
        ..add(u & 0xFF);
    }

    if (flag == lastFlag && repeatCount < 255) {
      if (repeatCount == 0) {
        flagBytes[flagBytes.length - 1] |= 0x08; // set repeat bit on flag
      }
      repeatCount++;
      if (repeatCount == 1) {
        flagBytes.add(1);
      } else {
        flagBytes[flagBytes.length - 1] = repeatCount;
      }
    } else {
      repeatCount = 0;
      flagBytes.add(flag);
      lastFlag = flag;
    }

    lastX = pt.x;
    lastY = pt.y;
  }

  final result = BytesBuilder(copy: false);
  result.add(header.buffer.asUint8List(0, 10));
  result.add(endPtsBuf.buffer.asUint8List(0, nContours * 2));
  result.add(instrHdr.buffer.asUint8List(0, 2));
  result.add(instrBytes);
  result.add(flagBytes);
  result.add(xCoords);
  result.add(yCoords);
  return result.takeBytes();
}

// ── Build loca table ──────────────────────────────────────────────────────────

Uint8List _buildLoca(List<int> values, int indexFormat) {
  final n = values.length;
  if (indexFormat != 0) {
    final buf = ByteData(n * 4);
    for (int i = 0; i < n; i++) {
      buf.setUint32(i * 4, values[i], Endian.big);
    }
    return buf.buffer.asUint8List(0, n * 4);
  } else {
    final buf = ByteData(n * 2);
    for (int i = 0; i < n; i++) {
      buf.setUint16(i * 2, values[i] >> 1, Endian.big);
    }
    return buf.buffer.asUint8List(0, n * 2);
  }
}

// ── Reconstruct transformed glyf + loca ──────────────────────────────────────

/// Returns (glyfData, locaData, xMins, numGlyphs, indexFormat) or nulls on error.
(Uint8List?, Uint8List?, List<int>?, int, int) _reconstructGlyf(
  Uint8List t, // transformed glyf data
  int locaDstLength,
) {
  if (t.length < 36) return (null, null, null, 0, 0); // 8-byte hdr + 7*4 sizes

  final bd = ByteData.sublistView(t);

  // Header: version(2) flags(2) numGlyphs(2) indexFormat(2) = 8 bytes
  // Then 7 substream sizes: 7*4 = 28 bytes.  Total header = 36 bytes.
  final flags = bd.getUint16(2);
  final hasOverlapBitmap = (flags & 1) != 0;
  final numGlyphs = bd.getUint16(4);
  final indexFormat = bd.getUint16(6);

  final expectedLocaSize = (indexFormat != 0 ? 4 : 2) * (numGlyphs + 1);
  if (expectedLocaSize != locaDstLength) return (null, null, null, 0, 0);

  const kSubs = 7;
  final subSizes = List<int>.generate(kSubs, (i) => bd.getUint32(8 + i * 4));

  // Compute absolute positions for each substream.
  final subStarts = <int>[];
  var off = 36;
  for (int i = 0; i < kSubs; i++) {
    subStarts.add(off);
    off += subSizes[i];
  }
  if (off > t.length) return (null, null, null, 0, 0);

  // Overlap bitmap (optional) immediately after the 7 substreams.
  final overlapBitmapStart = off;
  if (hasOverlapBitmap) {
    final bitmapLen = (numGlyphs + 7) >> 3;
    if (off + bitmapLen > t.length) return (null, null, null, 0, 0);
  }

  // Stream positions (advance as we consume each glyph).
  var nContourPos = subStarts[0];
  var nPointsPos = subStarts[1];
  var flagPos = subStarts[2];
  var glyphPos = subStarts[3]; // triplet data + instruction sizes
  var compositePos = subStarts[4];
  // bbox stream: bitmap first, then 8 bytes per "have_bbox" glyph.
  final bboxBitmapLen = ((numGlyphs + 31) >> 5) << 2; // round up to 4 bytes
  if (subStarts[5] + bboxBitmapLen > t.length) return (null, null, null, 0, 0);
  var bboxDataPos = subStarts[5] + bboxBitmapLen;
  var instrPos = subStarts[6];

  final glyfOut = BytesBuilder(copy: false);
  final locaValues = <int>[];
  final xMins = List<int>.filled(numGlyphs, 0);
  final pts = <({int x, int y, bool onCurve})>[];

  for (int i = 0; i < numGlyphs; i++) {
    if (nContourPos + 2 > t.length) return (null, null, null, 0, 0);
    final nContoursU = bd.getUint16(nContourPos);
    nContourPos += 2;

    final haveBbox = (t[subStarts[5] + (i >> 3)] & (0x80 >> (i & 7))) != 0;

    locaValues.add(glyfOut.length);

    if (nContoursU == 0xFFFF) {
      // ── composite glyph ────────────────────────────────────────────────────
      if (!haveBbox) {
        return (null, null, null, 0, 0); // composites must have bbox
      }

      final (compSize, haveInstr) = _sizeOfComposite(t, compositePos);
      if (compSize < 0) return (null, null, null, 0, 0);

      int instrSize = 0;
      if (haveInstr) {
        final (ok, sz, np) = _read255UShort(t, glyphPos);
        if (!ok) return (null, null, null, 0, 0);
        instrSize = sz;
        glyphPos = np;
      }

      // nContours (2) + bbox (8) + composite data + [instrLen (2) + instr]
      final glyfChunk = BytesBuilder(copy: false);

      final hdrBuf = ByteData(2);
      hdrBuf.setInt16(0, -1, Endian.big); // n_contours = 0xFFFF
      glyfChunk.add(hdrBuf.buffer.asUint8List(0, 2));

      if (bboxDataPos + 8 > t.length) return (null, null, null, 0, 0);
      glyfChunk.add(Uint8List.sublistView(t, bboxDataPos, bboxDataPos + 8));
      // Extract xMin from bbox for hmtx reconstruction (offset 0 in bbox = xMin)
      xMins[i] = bd.getInt16(bboxDataPos);
      bboxDataPos += 8;

      if (compositePos + compSize > t.length) return (null, null, null, 0, 0);
      glyfChunk.add(
        Uint8List.sublistView(t, compositePos, compositePos + compSize),
      );
      compositePos += compSize;

      if (haveInstr) {
        final instrHdr = ByteData(2);
        instrHdr.setUint16(0, instrSize, Endian.big);
        glyfChunk.add(instrHdr.buffer.asUint8List(0, 2));
        if (instrPos + instrSize > t.length) return (null, null, null, 0, 0);
        glyfChunk.add(Uint8List.sublistView(t, instrPos, instrPos + instrSize));
        instrPos += instrSize;
      }

      final chunk = glyfChunk.takeBytes();
      glyfOut.add(chunk);
    } else if (nContoursU > 0) {
      // ── simple glyph ───────────────────────────────────────────────────────
      final nContours = nContoursU;
      final nPointsVec = <int>[];
      int totalPts = 0;
      for (int j = 0; j < nContours; j++) {
        final (ok, np, pp) = _read255UShort(t, nPointsPos);
        if (!ok) return (null, null, null, 0, 0);
        nPointsPos = pp;
        nPointsVec.add(np);
        totalPts += np;
      }

      if (flagPos + totalPts > t.length) return (null, null, null, 0, 0);
      final flagSlice = Uint8List.sublistView(t, flagPos, flagPos + totalPts);
      flagPos += totalPts;

      pts.clear();
      final glyphDLen = subSizes[3] - (glyphPos - subStarts[3]);
      final (pok, consumed) = _tripletDecode(
        flagSlice,
        t,
        glyphPos,
        glyphDLen,
        totalPts,
        pts,
      );
      if (!pok) return (null, null, null, 0, 0);
      glyphPos += consumed;

      final (iok, instrSize, gp2) = _read255UShort(t, glyphPos);
      if (!iok) return (null, null, null, 0, 0);
      glyphPos = gp2;

      if (instrPos + instrSize > t.length) return (null, null, null, 0, 0);
      final instrBytes = Uint8List.sublistView(
        t,
        instrPos,
        instrPos + instrSize,
      );
      instrPos += instrSize;

      final hasOverlapBit =
          hasOverlapBitmap &&
          (t[overlapBitmapStart + (i >> 3)] & (0x80 >> (i & 7))) != 0;

      int xMin, yMin, xMax, yMax;
      if (haveBbox) {
        if (bboxDataPos + 8 > t.length) return (null, null, null, 0, 0);
        xMin = bd.getInt16(bboxDataPos);
        yMin = bd.getInt16(bboxDataPos + 2);
        xMax = bd.getInt16(bboxDataPos + 4);
        yMax = bd.getInt16(bboxDataPos + 6);
        bboxDataPos += 8;
      } else {
        if (totalPts == 0) {
          xMin = yMin = xMax = yMax = 0;
        } else {
          xMin = xMax = pts[0].x;
          yMin = yMax = pts[0].y;
          for (int j = 1; j < totalPts; j++) {
            if (pts[j].x < xMin) xMin = pts[j].x;
            if (pts[j].x > xMax) xMax = pts[j].x;
            if (pts[j].y < yMin) yMin = pts[j].y;
            if (pts[j].y > yMax) yMax = pts[j].y;
          }
        }
      }

      xMins[i] = xMin;

      final glyfBytes = _buildSimpleGlyph(
        nContours,
        xMin,
        yMin,
        xMax,
        yMax,
        nPointsVec,
        pts,
        instrBytes,
        hasOverlapBit,
      );
      glyfOut.add(glyfBytes);
    } else {
      // empty glyph (nContours == 0)
      if (haveBbox) return (null, null, null, 0, 0);
    }

    // Pad glyph to 4-byte boundary.
    final cur = glyfOut.length;
    final pad = ((cur + 3) & ~3) - cur;
    if (pad > 0) glyfOut.add(Uint8List(pad));
  }

  locaValues.add(glyfOut.length);
  final glyfData = glyfOut.takeBytes();
  final locaData = _buildLoca(locaValues, indexFormat);

  return (glyfData, locaData, xMins, numGlyphs, indexFormat);
}

// ── Reconstruct transformed hmtx ─────────────────────────────────────────────

Uint8List? _reconstructHmtx(
  Uint8List src,
  int numGlyphs,
  int numHMetrics,
  List<int> xMins,
) {
  if (src.isEmpty) return null;
  final hmtxFlags = src[0];
  if ((hmtxFlags & 0xFC) != 0) return null; // bits 2–7 must be 0

  final hasProportionalLsbs = (hmtxFlags & 1) == 0;
  final hasMonospaceLsbs = (hmtxFlags & 2) == 0;
  if (hasProportionalLsbs && hasMonospaceLsbs) return null;

  if (numHMetrics < 1 || numHMetrics > numGlyphs) return null;

  final bd = ByteData.sublistView(src);
  var pos = 1;

  // Advance widths (numHMetrics uint16).
  final advWidths = List<int>.filled(numHMetrics, 0);
  for (int i = 0; i < numHMetrics; i++) {
    if (pos + 2 > src.length) return null;
    advWidths[i] = bd.getUint16(pos);
    pos += 2;
  }

  final lsbs = List<int>.filled(numGlyphs, 0);

  // Proportional lsbs (first numHMetrics glyphs).
  for (int i = 0; i < numHMetrics; i++) {
    if (hasProportionalLsbs) {
      if (pos + 2 > src.length) return null;
      lsbs[i] = bd.getInt16(pos);
      pos += 2;
    } else {
      lsbs[i] = i < xMins.length ? xMins[i] : 0;
    }
  }

  // Monospace lsbs (remaining glyphs).
  for (int i = numHMetrics; i < numGlyphs; i++) {
    if (hasMonospaceLsbs) {
      if (pos + 2 > src.length) return null;
      lsbs[i] = bd.getInt16(pos);
      pos += 2;
    } else {
      lsbs[i] = i < xMins.length ? xMins[i] : 0;
    }
  }

  // Output: for i < numHMetrics: uint16 advWidth + int16 lsb; else int16 lsb.
  final outLen = 2 * numGlyphs + 2 * numHMetrics;
  final out = ByteData(outLen);
  var op = 0;
  for (int i = 0; i < numGlyphs; i++) {
    if (i < numHMetrics) {
      out.setUint16(op, advWidths[i], Endian.big);
      op += 2;
    }
    out.setInt16(op, lsbs[i], Endian.big);
    op += 2;
  }
  return out.buffer.asUint8List(0, outLen);
}

// ── Main WOFF2 decoder ────────────────────────────────────────────────────────

Uint8List? _decodeWoff2(Uint8List woff) {
  // ── 1. Parse WOFF2 header (48 bytes) ────────────────────────────────────────
  if (woff.length < 48) return null;
  final hd = ByteData.sublistView(woff);

  final flavor = hd.getUint32(4);
  // TTC collections not supported.
  if (flavor == 0x74746366) return null; // 'ttcf'

  final numTables = hd.getUint16(12);
  if (numTables == 0) return null;

  final compressedLength = hd.getUint32(20);

  // ── 2. Parse table directory ─────────────────────────────────────────────────
  var pos = 48;
  final entries = <_W2Entry>[];
  int srcOffsetAccum = 0;

  for (int i = 0; i < numTables; i++) {
    if (pos >= woff.length) return null;
    final flagByte = woff[pos++];
    final tagIndex = flagByte & 0x3F;
    final xformVersion = (flagByte >> 6) & 0x03;

    int tag;
    if (tagIndex == 0x3F) {
      if (pos + 4 > woff.length) return null;
      tag = hd.getUint32(pos);
      pos += 4;
    } else {
      tag = _kW2Tags[tagIndex];
    }

    final bool isTransformed;
    if (tag == 0x676C7966 || tag == 0x6C6F6361) {
      // glyf or loca: xformVersion == 0 means IS transformed
      isTransformed = xformVersion == 0;
    } else {
      isTransformed = xformVersion != 0;
    }

    final (ok1, dstLength, p1) = _base128(woff, pos);
    if (!ok1) return null;
    pos = p1;

    int transformLength = dstLength;
    if (isTransformed) {
      final (ok2, tl, p2) = _base128(woff, pos);
      if (!ok2) return null;
      transformLength = tl;
      pos = p2;
      // Transformed loca must have transformLength == 0.
      if (tag == 0x6C6F6361 && transformLength != 0) return null;
    }

    entries.add(
      _W2Entry(
        tag: tag,
        isTransformed: isTransformed,
        srcOffset: srcOffsetAccum,
        srcLength: transformLength,
        dstLength: dstLength,
      ),
    );
    srcOffsetAccum += transformLength;
  }

  // ── 3. Brotli decompress ──────────────────────────────────────────────────────
  if (pos + compressedLength > woff.length) return null;

  Uint8List uncompressed;
  try {
    final slice = Uint8List.sublistView(woff, pos, pos + compressedLength);
    final decoded = brotliDecode(slice);
    uncompressed = decoded is Uint8List ? decoded : Uint8List.fromList(decoded);
  } catch (_) {
    return null;
  }

  if (uncompressed.length < srcOffsetAccum) return null;

  // ── 4. Reconstruct tables ─────────────────────────────────────────────────────
  final tableData = <int, Uint8List>{}; // tag → reconstructed bytes
  final tableChecksum = <int, int>{}; // tag → SFNT checksum
  List<int>? xMins;
  int numGlyphs = 0;
  int numHMetrics = 0;
  Uint8List? deferredHmtxSrc; // transformed hmtx needs glyf processed first

  // Pass 1: process all tables except transformed loca and transformed hmtx.
  for (final e in entries) {
    if (e.isTransformed && e.tag == 0x6C6F6361) continue; // rebuilt from glyf

    final src = e.srcLength > 0
        ? Uint8List.sublistView(
            uncompressed,
            e.srcOffset,
            e.srcOffset + e.srcLength,
          )
        : Uint8List(0);

    if (!e.isTransformed) {
      Uint8List data;
      if (e.tag == 0x68656164 && src.length >= 12) {
        // head: zero checkSumAdjustment (bytes 8–11) before checksumming.
        data = Uint8List.fromList(src);
        data[8] = data[9] = data[10] = data[11] = 0;
      } else {
        data = src;
      }
      if (e.tag == 0x68686561 && src.length >= 36) {
        // hhea: extract numberOfHMetrics at offset 34.
        numHMetrics = ByteData.sublistView(src).getUint16(34);
      }
      tableData[e.tag] = data;
      tableChecksum[e.tag] = _sfntChecksum(data);
    } else if (e.tag == 0x676C7966) {
      // Transformed glyf — also reconstructs loca.
      final locaEntry = entries.firstWhere(
        (e2) => e2.tag == 0x6C6F6361,
        orElse: () => _W2Entry(
          tag: 0x6C6F6361,
          isTransformed: true,
          srcOffset: 0,
          srcLength: 0,
          dstLength: 0,
        ),
      );
      final (glyf, loca, xm, ng, _) = _reconstructGlyf(
        src,
        locaEntry.dstLength,
      );
      if (glyf == null) return null;
      tableData[0x676C7966] = glyf;
      tableData[0x6C6F6361] = loca!;
      tableChecksum[0x676C7966] = _sfntChecksum(glyf);
      tableChecksum[0x6C6F6361] = _sfntChecksum(loca);
      xMins = xm;
      numGlyphs = ng;
    } else if (e.tag == 0x686D7478) {
      // Transformed hmtx: defer until glyf is processed (glyf < hmtx by tag).
      deferredHmtxSrc = src;
    } else {
      tableData[e.tag] = src;
      tableChecksum[e.tag] = _sfntChecksum(src);
    }
  }

  // Pass 2: reconstruct transformed hmtx using xMins from glyf.
  if (deferredHmtxSrc != null) {
    final hmtx = _reconstructHmtx(
      deferredHmtxSrc,
      numGlyphs,
      numHMetrics,
      xMins ?? const [],
    );
    if (hmtx == null) return null;
    tableData[0x686D7478] = hmtx;
    tableChecksum[0x686D7478] = _sfntChecksum(hmtx);
  }

  // ── 5. Assemble SFNT ──────────────────────────────────────────────────────────
  final sortedTags = tableData.keys.toList()..sort();
  final n = sortedTags.length;
  final headerSize = 12 + n * 16;

  // Compute table offsets (4-byte aligned after headers).
  final offsets = <int, int>{};
  var cursor = headerSize;
  for (final tag in sortedTags) {
    offsets[tag] = cursor;
    cursor += (tableData[tag]!.length + 3) & ~3;
  }

  final out = Uint8List(cursor);
  final w = out.buffer.asByteData();
  var p = 0;

  // SFNT offset table (12 bytes).
  w.setUint32(p, flavor);
  p += 4;
  w.setUint16(p, n);
  p += 2;
  final log2n = n > 0 ? (math.log(n) / math.log(2)).floor() : 0;
  final searchRange = (1 << log2n) * 16;
  w.setUint16(p, searchRange);
  p += 2;
  w.setUint16(p, log2n);
  p += 2;
  w.setUint16(p, n * 16 - searchRange);
  p += 2;

  // Table directory (n × 16 bytes).
  for (final tag in sortedTags) {
    w.setUint32(p, tag);
    p += 4;
    w.setUint32(p, tableChecksum[tag]!);
    p += 4;
    w.setUint32(p, offsets[tag]!);
    p += 4;
    w.setUint32(p, tableData[tag]!.length);
    p += 4;
  }

  // Table data.
  for (final tag in sortedTags) {
    final d = tableData[tag]!;
    out.setRange(offsets[tag]!, offsets[tag]! + d.length, d);
  }

  // Fix head.checkSumAdjustment (head was already zeroed above).
  if (offsets.containsKey(0x68656164)) {
    final fontChecksum = _sfntChecksum(out); // out already has checkSumAdj = 0
    final adjustment = (0xB1B0AFBA - fontChecksum) & 0xFFFFFFFF;
    w.setUint32(offsets[0x68656164]! + 8, adjustment);
  }

  return out;
}
