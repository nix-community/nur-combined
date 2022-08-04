{ stdenv
, sources
, lib
, fuse
, ...
} @ args:

stdenv.mkDerivation rec {
  inherit (sources.nullfs) pname version src;

  buildInputs = [ fuse ];

  installPhase = ''
    mkdir -p $out/bin
    cp nullfs $out/bin/nullfs
  '';

  meta = with lib; {
    description = "FUSE nullfs drivers";
    homepage = "https://github.com/xrgtn/nullfs";
  };
}
