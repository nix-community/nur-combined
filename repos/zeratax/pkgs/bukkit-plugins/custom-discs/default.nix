{
  lib,
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation rec {
  pname = "custom-discs";
  version = "5.1.2";
  owner = "Navoei";

  preferLocalBuild = true;

  dontUnpack = true;
  dontConfigure = true;

  installPhase = let
    jar = fetchurl {
      url = "https://github.com/${owner}/CustomDiscs/releases/download/v${version}/custom-discs-${version}.jar";
      sha256 = "1818qv95pdjlj4fflmy5605gah1y62p9i01wziq0z87zzy0684dp";
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
