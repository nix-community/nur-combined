{ lib, fetchurl, runCommand, libarchive }:
with lib.attrsets;
let
  version = "12.0";
  version-full = "${version}.0";
  files = {
    emoji-data = fetchurl {
      url = "http://www.unicode.org/Public/emoji/${version}/emoji-data.txt";
      sha256 = "03sf7h1d6kb9m5s02lif88jsi5kjszpkfvcymaqxj8ds70ar9pgv";
    };
    emoji-sequences = fetchurl {
      url = "http://www.unicode.org/Public/emoji/${version}/emoji-sequences.txt";
      sha256 = "1hghki2rn3n7m4lwpwi2a5wrsf2nij4bxga9ldabx4g0g2k23svs";
    };
    emoji-test = fetchurl {
      url = "http://www.unicode.org/Public/emoji/${version}/emoji-test.txt";
      sha256 = "1dqd0fh999mh6naj816ni113m9dimfy3ih9nffjq2lrv9mmlgdck";
    };
    emoji-variation-sequences = fetchurl {
      url = "http://www.unicode.org/Public/emoji/${version}/emoji-variation-sequences.txt";
      sha256 = "1cccwx5bl79w4c19vi5dhjqxrph92s8hihp9y8s2cqvdzmgbln7a";
    };
    emoji-zwj-sequences = fetchurl {
      url = "http://www.unicode.org/Public/emoji/${version}/emoji-zwj-sequences.txt";
      sha256 = "1l791nbijmmhwa7kmvfn8gp26ban512l6mgqpz1mnbq3xm19181n";
    };
  };
  zippedFiles = {
    UCD = fetchurl {
      url = "http://www.unicode.org/Public/zipped/${version-full}/UCD.zip";
      sha256 = "1ighy39cjkmqnv1797wrxjz76mv1fdw7zp5j04q55bkwxsdkvrmh";
    };
    Unihan = fetchurl {
      url = "http://www.unicode.org/Public/zipped/${version-full}/Unihan.zip";
      sha256 = "1kfdhgg2gm52x3s07bijb5cxjy0jxwhd097k5lqhvzpznprm6ibf";
    };
  };
in
  runCommand "unicode" {
    buildInputs = [ libarchive ];
  } ''
  mkdir -p $out/share/unicode
  ${builtins.concatStringsSep "\n" (mapAttrsToList (n: u: "install -Dm644 ${u} $out/share/unicode/emoji/${n}.txt") files)}
  ${builtins.concatStringsSep "\n" (mapAttrsToList (n: u: ''
    install -Dm644 ${u} $out/share/unicode/${n}.zip
    bsdtar -C "$out/share/unicode" -x -f "$out/share/unicode/${n}.zip"
    '') zippedFiles)}
  ''
