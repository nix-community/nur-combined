# portions of this inspired / stolen from:
# (MIT) Rust's core::str

let
  byteTables = import ./byte-tables.nix;
  inherit (builtins)
    bitAnd
    bitXor
    elemAt
    filter
    genList
    isString
    seq
    split
    trace;
  listFoldl' = builtins.foldl';

  _b0000_0000 =   0;
  _b0011_1111 =  63;
  _b1000_0000 = 128;
  _b1100_0000 = 192;
  _b1110_0000 = 224;
  _b1111_0000 = 240;
  _b1111_1000 = 248;
  _b1111_1100 = 252;
  _b1111_1110 = 254;
  _b1111_1111 = 255;

  nixpkgsLib = import <nixpkgs/lib>;
  # traceV = s: x: trace "${s}: ${toString x}" x;
  traceV = s: x: trace s (nixpkgsLib.traceValSeqN 1 x);
  traceM = s: x: y: trace s (nixpkgsLib.traceSeqN 1 x y);
in
rec {
# str N is a string of length (N::int)
# a utf8str is a str of valid UTF-8 characters
# a u8 is an integer byte
# a utf8byte is a u8 that may appear in valid UTF-8
# if a "type" (comment) assertion is broken,
#   an assert is triggered (return is bottom)

# strFoldl' op nul s :: (A, N::int) =>
#   (A -> str 1 -> A) -> A -> str N -> A;
strFoldl' = op: nul: s: listFoldl' op nul (strChars s);

# strChars s :: (N::int) => str N -> (str 1)[N];
strChars = s: genList (strCharAtUnsafe s) (strLength s);

# strLength :: (N::int) => str N -> N
strLength = builtins.stringLength;

# strCharAtUnsafe s n :: (N::int, M::int, (M<N)) => str N -> M -> str 1
# caller guarantees (M<N)
strCharAtUnsafe = s: n: strSliceUnsafe n 1 s;
# returns null if index `n` is invalid
# strCharAt' s n :: (N::int, M::int) => str N -> M -> (null + str 1)
strCharAt' = s: n: let t = strSliceUnsafe n 1 s; in if strLength t == 0 then null else t;
# strCharAt s n :: (N::int, M::int, (M<N)) => str N -> M -> str 1
strCharAt = s: n: let t = strSliceUnsafe n 1 s; in assert strLength t != 0; t;

strSliceUnsafe = builtins.substring;
# returns null first if length is negative
# returns null after if string does not contain byte range
# strSlice' start len s ::
#   (I::int, N::int, M::int) => I -> N -> (null + (str M -> (null + str N)))
strSlice' = start: len: if len < 0 then null else
  s: let t = strSliceUnsafe start len s; in
  if strLength t != len then null else t;
# strSlice start len s ::
#   (I::int, N::int, M::int, (N>=0), (I>=0), (I+N<=M)) =>
#   I -> N -> str M -> str N
strSlice = start: len: assert len >= 0;
  s: let t = strSliceUnsafe start len s; in
  assert strLength t == len; t;

# strTakeUnsafe n s :: (N::int, (N>=0), M::int, (N<=M)) => N -> str M -> str N
# caller guarantees: (N>=0), (N<=M)
strTakeUnsafe = strSliceUnsafe 0;
# returns null first if length is negative
# returns null after if string is not long enough
# strTake' n s :: (N::int, M::int) => N -> (null + str M -> (null + str N))
strTake' = n: if n < 0 then null else
  s: let t = strTakeUnsafe 0 n s; in
  if strLength t != n then null else t;
# strTake n s :: (N::int, (N>=0), M::int, (N<=M)) => N -> str M -> str N
strTake = n: assert n >= 0;
  s: let t = strSliceUnsafe 0 n s; in
  assert strLength t == n; t;

# strDropUnsafe n s :: (N::int, (N>=0), M::int, (N<=M)) => N -> str M -> str N
# caller guarantees (N>=0), (N<=M)
strDropUnsafe = n: strSliceUnsafe n (-1);
# strDrop' n s :: (N::int, M::int) => N -> (null + str M -> (null + str N))
strDrop' = n: if n < 0 then null else
  s: if n > strLength s then null else strSliceUnsafe n (-1) s;
# strDrop n s :: (N::int, (N>=0), M::int, (N<=M)) => N -> str M -> str N
strDrop = n: assert n >= 0;
  s: assert n <= strLength s; strSliceUnsafe n (-1) s;

# strHeadUnsafe s :: (N::int, (N>0)) => str N => str 1
# caller guarantees (N>0)
strHeadUnsafe = strTakeUnsafe 1;
# strHead' s :: (N::int) => str N -> (null + str 1)
strHead' = strTake' 1;
# strHead s :: (N::int, (N>0)) => str N -> str 1
strHead = strTake 1;

# strLastUnsafe s :: (N::int, (N>0)) => str N => str 1
# caller guarantees (N>0)
strLastUnsafe = s: strSliceUnsafe (strLength s - 1) 1 s;
# strLast' s :: (N::int) => str N -> (null + str 1)
strLast' = s: let len = strLength s; in if len == 0 then null else
  strSliceUnsafe (len - 1) 1 s;
# strLast s :: (N::int, (N>0)) => str N -> str 1
strLast = s: let len = strLength s; in assert len != 0;
  strSliceUnsafe (len - 1) 1 s;

# strInit s :: (N::int, (N>0)) => str N -> str (N-1)
# caller guarantees (N>0)
strInitUnsafe = s: strSliceUnsafe 0 (strLength s - 1) s;
# strInit' s :: (N::int) => str N -> (null + str (N-1))
strInit' = s: let len = strLength s; in if len == 0 then null else
  strSliceUnsafe (len - 1) 1 s;
# strInit s :: (N::int, (N>0)) => str N -> str (N-1)
strInit = s: let len = strLength s; in assert len != 0;
  strSliceUnsafe (len - 1) 1 s;

# strTailUnsafe s :: (N::int, (N>0)) => str N -> str (N-1)
# caller guarantees (N>0)
strTailUnsafe = strDropUnsafe 1;
# strTail' s :: (N::int) => str N -> (null + str (N-1))
strTail' = strDrop' 1;
# strTail s :: (N::int, (N>0)) => str N -> str (N-1)
strTail = strDrop 1;

# strUnconsUnsafe s :: (N::int, (N>0)) => str N -> [ (str 1) (str (N-1)) ]
strUnconsUnsafe = s: [ (strHeadUnsafe s) (strTailUnsafe s) ];
# strUncons' s :: (N::int) => str N -> (null + [ (str 1) (str (N-1)) ])
strUncons' = s: let len = strLength s; in if len == 0 then null else
  [ (strHeadUnsafe s) (strSliceUnsafe (strLength - 1) 1 s) ];
# strUncons s :: (N::int, (N>0)) => str N -> [ (str 1) (str (N-1)) ]
strUncons = s: let len = strLength s; in assert len != 0;
  [ (strHeadUnsafe s) (strSliceUnsafe (len - 1) 1 s) ];

# strUnsnocUnsafe s :: (N::int, (N>0)) => str N -> [ (str (N-1)) (str 1) ]
# caller guarantees (N>0)
strUnsnocUnsafe = s: let len = strLength s; in
  [ (strSliceUnsafe 0 (len - 1) s) (strSliceUnsafe (len - 1) len s) ];
# strUnsnoc' s :: (N::int) => str N -> (null + [ (str (N-1)) (str 1) ])
strUnsnoc' = s: let len = strLength s; in if len == 0 then null else
  [ (strSliceUnsafe 0 (len - 1) s) (strSliceUnsafe (len - 1) len s) ];
# strUnsnoc s :: (N::int, (N>0)) => str N -> [ (str (N-1)) (str 1) ]
strUnsnoc = s: let len = strLength s; in assert len != 0;
  [ (strSliceUnsafe 0 (len - 1) s) (strSliceUnsafe (len - 1) len s) ];

# byteCharWidthTable :: (N::int, (0<=N<=4)) => N[256]
byteCharWidthTable = byteTables.byteCharWidth;
# charWidthTable :: (N::int, (0<=N<=4)) => str 1 -> N
charWidthTable = byteTables.charWidth;
# fromByteTable :: (I == 0 ? null : str 1)[256]
fromByteTable = byteTables.from;
# toByteTable :: {${str 1} = int}
toByteTable = byteTables.to;

# byteCharWidth :: (N::u8, M::int, (0<=M<=4)) => N -> M
byteCharWidth = elemAt byteCharWidthTable;
# charWidth :: (N::int, (0<=N<=4)) => str 1 -> N
charWidth = c: charWidthTable.${c};
# fromByte :: (N::u8, (N>1)) => N -> str 1
fromByte = elemAt fromByteTable;
# toByte :: (N::u8, (N>1)) => str 1 -> N
toByte = c: toByteTable.${c};

continuationMask = _b0011_1111;
continuationTagBits = _b1000_0000;

# isContinuationByte :: u8 -> bool
isContinuationByte = let
  bits = bitXor _b1111_1111 continuationMask; in
  b: bitAnd bits == continuationTagBits;

# isContinuationChar :: str 1 -> bool
isContinuationChar = c: charWidthTable.${c} == -1;

# match patterns (0x):
#   1 wide: [00-7F]
#   2 wide: [C2-DF][80-BF]
#   3 wide: [E0-EF][80-BF][80-BF]
#   4 wide: [F0-F4][80-BF][80-BF][80-BF]
continuationPat = "[${fromByte 128}-${fromByte 191}]";
width1Pat = "[${fromByte 001}-${fromByte 127}]";
firstWidth2Pat = "[${fromByte 194}-${fromByte 223}]";
width2Pat = firstWidth2Pat + continuationPat;
firstWidth3Pat = "[${fromByte 224}-${fromByte 239}]";
width3Pat = firstWidth3Pat + continuationPat + continuationPat;
firstWidth4Pat = "[${fromByte 240}-${fromByte 244}]";
width4Pat = firstWidth4Pat +
  continuationPat + continuationPat + continuationPat;
charPat = "${width1Pat}|${width2Pat}|${width3Pat}|${width4Pat}";

# foldl' op nul s :: (A_N, N::int, (N>0)) =>
#   (A_n -> utf8str 1 -> A_n+1) -> A_0 -> utf8str N -> (null + A_N);
foldl' =
  let go = op: s: let
    len = strLength s;
    go' = i: acc: let
      c = strCharAtUnsafe s i;
      w = charWidth c; in
      if w <= 0 then null else
      if w == 1 then
        newAcc = op acc c;
        newI = i + 1; in
        if newI >= len then acc else
        seq newAcc (go' newI newAcc); in
      else let
        sCharAtUnsafe = strCharAtUnsafe s;
        c = strSliceUnsafe i w s;
        if !(isContinuationChar (sCharAtUnsafe (i+1))) then null else
        if w > 1 && !(isContinuationChar (sCharAtUnsafe (i+2))) then null else
        if w > 2 && !(isContinuationChar (sCharAtUnsafe (i+3))) then null else
        if w == 4 && !(isContinuationChar (sCharAtUnsafe (i+4))) then null else
        newAcc = op acc c;
        newI = i + w; in
        if newI >= len then acc else
        seq newAcc (go' newI newAcc); in
    go'; in
  op: nul: s: go op s 0 nul;

# chars s :: (N::int) => utf8str N -> (utf8str 1)[N];
chars'Fold = foldl' (xs: x: xs ++ [x]) [ ];
charsSplit = let
  p = x: if isString x then assert x == ""; false else true;
  f = x: builtins.elemAt x 0; in
  s: map f (filter p (split "(${charPat})" s));
charsSplit = let
  p = x: if isString x then assert x == ""; false else true;
  f = x: builtins.elemAt x 0; in
  s: map f (filter p (split "(${charPat})" s));
chars' = chars'Fold;
chars = charsSplit;
}

# vim: fenc=utf-8:ft=nix
