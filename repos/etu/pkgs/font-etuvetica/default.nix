{
  lib,
  stdenv,
  fetchurl,
  ...
}:
stdenv.mkDerivation {
  pname = "etuvetica";
  version = "1";

  src = fetchurl {
    url = "https://elis.nu/etuvetica/css/fonts/etuvetica.ttf";
    hash = "sha256-sog/24O8spgjW95haRIRNfVeckifOcNJ8RZ1fnBwPHw=";
  };

  dontUnpack = true;

  installPhase = "install --mode=644 -D $src $out/share/fonts/truetype/etuvetica.ttf";

  meta = with lib; {
    description = "etu's terrible font";
    homepage = "https://elis.nu/etuvetica";
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
