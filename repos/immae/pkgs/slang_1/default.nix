{ stdenv, fetchpatch, fetchurl }:
stdenv.mkDerivation rec {
  name = "slang-debian-patched-${version}";
  version = "1.4.9";
  src = fetchurl {
    url = "ftp://space.mit.edu/pub/davis/slang/v1.4/slang-1.4.9.tar.gz";
    sha256 = "1y2mg0whqh4b3acd0k17i4biz55bimxg8aaxhmwd165cvspxns9r";
  };
  patches = [
    (fetchpatch {
      name = "slang_1.4.9dbs-8.diff.gz";
      url = "http://archive.debian.org/debian-archive/debian-amd64/pool/main/s/slang/slang_1.4.9dbs-8.diff.gz";
      sha256 = "0xdq14k5ynqfwpmis1rcggs7m4n921i3bs27icbmbhfg5gb2hap2";
    })
  ];
  preConfigure = ''
    for i in debian/patches/*; do
      patch -p1 < $i
    done
    makeFlagsArray=(CFLAGS=" -g -O2 -fno-strength-reduce -DUTF8 -D_REENTRANT -D_XOPEN_SOURCE=500")
    '';
  postBuild = ''
    sed -i "1i#ifndef UTF8\n#define UTF8\n#endif" src/slang.h
    '';
}
