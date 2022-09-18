{ stdenv
, sources
, lib
, ...
} @ args:

stdenv.mkDerivation rec {
  pname = "dn42-pingfinder";
  version = "1.0.0";
  src = ./dn42-pingfinder.sh;

  dontUnpack = true;
  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/dn42-pingfinder
    chmod +x $out/bin/dn42-pingfinder
  '';

  meta = with lib; {
    description = "DN42 Pingfinder";
    homepage = "https://git.dn42.dev/dn42/pingfinder/src/branch/master/clients";
    license = licenses.unfreeRedistributable;
  };
}
