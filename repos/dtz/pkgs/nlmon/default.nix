{ stdenv, fetchgit }:

stdenv.mkDerivation {
  pname = "nlmon";
  version = "2015-07-28";

  src = fetchgit {
    url = "git://r-36.net/nlmon";
    rev = "5881cff90359800b1d01ebc0bf35f53f4a67815d";
    sha256 = "0q5pkf3h7rsm3w27s61kwaa3023drxpb2fmynrp7pra26z4dwzgk";
  };

  # Add glibc.static for glibc-based stdenv, etc.
  buildInputs = [ (stdenv.lib.getOutput "static" stdenv.cc.libc) ];

  postPatch = ''
    substituteInPlace config.mk \
      --replace "-lc" "" \
      --replace "-O0" ""
  '';

  makeFlags =  [ "PREFIX=${placeholder "out"}" ];
}
