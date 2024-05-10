{ config
, lib
, stdenv
, fetchzip
}:

stdenv.mkDerivation rec {
  pname = "xlink_kai";
  version = "7.4.45-651430714";

  src = fetchzip {
    url = "https://dist.teamxlink.co.uk/linux/debian/static/standalone/release/amd64/xlinkkai_7.4.45_651430714_standalone_x86_64.tar.gz";
    hash = "sha256-+ZV3R6EybIEFC+oRV7tLIhgAeYxbi4Ss18g5ouBamTY=";
  };
  
  installPhase = ''
    mkdir -p $out/bin
    cp kaiengine $out/bin
  '';

  meta = with lib; {
    description = "Global Network Gaming";
    homepage = "https://www.teamxlink.co.uk/";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
  };
}
