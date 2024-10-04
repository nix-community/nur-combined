{
  lib,
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation rec {
  pname = "custom-discs";
  version = "3.0";
  owner = "Navoei";

  preferLocalBuild = true;

  dontUnpack = true;
  dontConfigure = true;

  installPhase = let
    jar = fetchurl {
      url = "https://github.com/${owner}/CustomDiscs/releases/download/v${version}/custom-discs-${version}.jar";
      sha256 = "0xv0zrkdmjx0d7l34nqag8j004pm9zqivc12d3zy9pdrkv7pz87d";
    };
  in ''
    mkdir -p $out
    cp ${jar} $out/${pname}.jar
  '';

  meta = with lib; {
    homepage = "https://github.com/Navoei/CustomDiscs";
    description = "A Paper plugin to add custom music discs using the Simple Voice Chat API.";
    maintainers = with maintainers; [zeratax];
  };
}
