{
  lib,
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation rec {
  pname = "custom-discs";
  version = "5.2.0";

  preferLocalBuild = true;

  dontUnpack = true;
  dontConfigure = true;

  installPhase = let
    jar = fetchurl {
      url = "https://cdn.modrinth.com/data/b7pWaVta/versions/TzveQutv/custom-discs-${version}.jar";
      sha256 = "0n8w3skqyhbz46im2i9xdy53zqvz2gaw0dgvl879jv47ym1r891i";
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
