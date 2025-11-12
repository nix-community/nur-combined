{
  lib,
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation rec {
  pname = "bluemap-marker-manger";
  version = "2.1.12";
  owner = "MiraculixxT";

  preferLocalBuild = true;

  dontUnpack = true;
  dontConfigure = true;

  installPhase = let
    jar = fetchurl {
      url = "https://cdn.modrinth.com/data/a8UoyV2h/versions/jRs3jUlU/bmm-paper-2.1.12.jar";
      sha256 = "1z9if0a8pkbra001s60zrrp08cq6cwzk74s5wv7rnfxkl7zl89sn";
    };
  in ''
    mkdir -p $out
    echo "${jar}"
    cp "${jar}" $out/${pname}.jar
  '';

  meta = with lib; {
    homepage = "https://modrinth.com/plugin/bmarker";
    description = "BlueMap extension - Add a marker command to easily setup your markers & marker sets ingame without touching any configs";
    maintainers = with maintainers; [zeratax];
  };
}
