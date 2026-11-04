import '../helper.dart';

// ignore_for_file: public_member_api_docs

final List<int> lookup = _unpackLookupTable(
  "         !!  !                  \"#\$##%#\$&'##(#)#++++++++++((&*'##,---,---,-----,-----,-----&#'###.///.///./////./////./////&#'# ",
  "A/*  ':  & : \$  \u0081 @",
);

List<int> _unpackLookupTable(
  String map,
  String rle,
) {
  final lookup = createInt32List(2048);

  for (var i = 0; i < 256; ++i) {
    lookup[i] = i & 0x3F;
    lookup[512 + i] = i >> 2;
    lookup[1792 + i] = 2 + (i >> 6);
  }

  for (var i = 0; i < 128; ++i) {
    lookup[1024 + i] = 4 * (map.codeUnitAt(i) - 32);
  }

  for (var i = 0; i < 64; ++i) {
    lookup[1152 + i] = i & 1;
    lookup[1216 + i] = 2 + (i & 1);
  }

  var offset = 1280;

  for (var k = 0; k < 19; ++k) {
    final value = k & 3;
    final rep = rle.codeUnitAt(k) - 32;

    for (var i = 0; i < rep; ++i) {
      lookup[offset++] = value;
    }
  }

  for (var i = 0; i < 16; ++i) {
    lookup[1792 + i] = 1;
    lookup[2032 + i] = 6;
  }

  lookup[1792] = 0;
  lookup[2047] = 7;

  for (var i = 0; i < 256; ++i) {
    lookup[1536 + i] = lookup[1792 + i] << 3;
  }

  return lookup;
}
