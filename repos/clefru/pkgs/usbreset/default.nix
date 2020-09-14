{ stdenv }:

stdenv.mkDerivation {
  name = "usbreset";
  src = ./usbreset.cc;
  unpackPhase = "true";
  buildPhase = ''cc $src -o usbreset'';
  installPhase = ''mkdir -p $out/bin; install usbreset $out/bin'';
}
