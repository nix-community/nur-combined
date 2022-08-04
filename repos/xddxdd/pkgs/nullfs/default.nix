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
    cp nul1fs nullfs nulnfs $out/bin/
  '';

  meta = with lib; {
    description = "FUSE nullfs drivers";
    homepage = "https://github.com/xrgtn/nullfs";
  };
}
