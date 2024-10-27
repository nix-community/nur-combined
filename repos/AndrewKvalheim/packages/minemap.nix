{ fetchurl
, fetchFromGitHub
, imagemagick
, lib
, makeDesktopItem
, makeWrapper
, nix-update-script
, stdenv

  # Dependencies
, jre
}:

stdenv.mkDerivation rec {
  pname = "minemap";
  version = "1.0.26";

  src = fetchurl {
    url = "https://github.com/hube12/Minemap/releases/download/${version}/MineMap-${version}.jar";
    hash = "sha256-Vge4C6X1W4M7w+s9ivZAiRp9k/8plpA6A5SeJgylqdw=";
  };
  dontUnpack = true;

  iconSrc = fetchFromGitHub {
    owner = "hube12";
    repo = "Minemap";
    rev = "d766d547c86d9405a26a775899d435efdcd20f60";
    sparseCheckout = [ "logo.png" ];
    hash = "sha256-FNCVw0Dj0FXl0dgmzpH+s8PH8DIUq4qwJBnjpQIGgMs=";
  };

  desktopItem = makeDesktopItem {
    categories = [ "Utility" "Viewer" ];
    genericName = "Minecraft seed viewer";
    desktopName = "Minemap";
    name = pname;
    icon = pname;
    exec = meta.mainProgram;
  };

  nativeBuildInputs = [ imagemagick makeWrapper ];
  buildPhase = ''
    magick $iconSrc/logo.png -crop '68x68+44+7' +repage \
      \( +clone -crop '4x38+0+22' -geometry '+64+26' -flop \) \
      -compose copy -composite -filter 'point' -resize '200%' ${pname}.png
  '';
  installPhase = ''
    install -D $src $out/share/${pname}.jar
    makeWrapper ${jre}/bin/java $out/bin/${pname} \
      --add-flags "-jar $out/share/${pname}.jar"

    install -D -t $out/share/icons ${pname}.png
    install -D -t $out/share/applications ${desktopItem}/share/applications/*
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Efficient map viewer for Minecraft seed in a nice GUI with utilities";
    homepage = "https://github.com/hube12/Minemap";
    license = lib.licenses.mit;
    mainProgram = pname;
  };
}
