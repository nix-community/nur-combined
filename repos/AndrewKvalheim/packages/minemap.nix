{ copyDesktopItems
, fetchurl
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

let
  inherit (lib) getExe;
in
stdenv.mkDerivation (minemap: {
  pname = "minemap";
  version = "1.0.26";

  src = fetchurl {
    url = "https://github.com/hube12/Minemap/releases/download/${minemap.version}/MineMap-${minemap.version}.jar";
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

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Utility" "Viewer" ];
      genericName = "Minecraft seed viewer";
      desktopName = "Minemap";
      name = minemap.pname;
      icon = minemap.pname;
      exec = "@out@/bin/minemap";
    })
  ];

  nativeBuildInputs = [ copyDesktopItems imagemagick makeWrapper ];
  buildPhase = ''
    magick $iconSrc/logo.png -crop '68x68+44+7' +repage \
      \( +clone -crop '4x38+0+22' -geometry '+64+26' -flop \) \
      -compose copy -composite -filter 'point' -resize '200%' ${minemap.pname}.png
  '';
  postInstall = ''
    install -D $src $out/share/minemap.jar
    makeWrapper ${getExe jre} $out/bin/minemap \
      --add-flags "-jar $out/share/minemap.jar"

    install -D -t $out/share/icons ${minemap.pname}.png
  '';

  preFixup = ''
    substituteAllInPlace $out/share/applications/*
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Efficient map viewer for Minecraft seed in a nice GUI with utilities";
    homepage = "https://github.com/hube12/Minemap";
    license = lib.licenses.mit;
    mainProgram = "minemap";
  };
})
