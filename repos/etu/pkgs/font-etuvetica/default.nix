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
    sha256 = "0z1wf1q7wx8ny54w6fcz91r5xx9m2496jqfybciricmwhgdkz25j";
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
