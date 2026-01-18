{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  pkg-config,
  SDL2,
  SDL2_mixer,
  makeDesktopItem,
  copyDesktopItems,
}:

stdenv.mkDerivation rec {
  pname = "ccleste";
  version = "1.4.0-unstable-2025-01-18";

  src = fetchFromGitHub {
    owner = "LonkToThePast";
    repo = "ccleste";
    rev = "9a17a16de3006dbf2c5af79bd13e1d7c67fc7d31";
    sha256 = "sha256-gxH1oKz+Q64ARM4yshGPNUp89TCO9hb0CGd1+/SC5Y4=";
  };

  nativeBuildInputs = [
    pkg-config
    copyDesktopItems
  ];

  buildInputs = [
    SDL2
    SDL2_mixer
  ];

  makeFlags = [
    "USE_FIXEDP=1"
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "ccleste";
      desktopName = "Ccleste";
      exec = "ccleste";
      icon = "ccleste";
      comment = "Celeste Classic C source port";
      categories = [
        "Game"
        "ActionGame"
      ];
    })
  ];

  patches = [
    ./fix-palette.patch
  ]; 

  postPatch = ''
    substituteInPlace sdl12main.c \
      --replace-fail 'snprintf(path, n, "data%c%s", pathsep, fname);' \
                'snprintf(path, n, "'$out'/share/ccleste/data%c%s", pathsep, fname);'
  '';

  installPhase =
    let
      icon = fetchurl {
        url = "https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-icon-theme/master/Papirus/64x64/apps/celeste.svg";
        sha256 = "sha256-PS43zAYy/+oNm8ykTvi/aGv8vWxVtqnbaKtVJI/prNY=";
      };
    in
    ''
      runHook preInstall
      mkdir -p $out/bin $out/share/ccleste $out/share/icons/hicolor/scalable/apps
      
      if [ -f ccleste-fixedp ]; then
        cp ccleste-fixedp $out/bin/ccleste
      else
        cp ccleste $out/bin/
      fi
      
      cp -r data $out/share/ccleste/

      # Install icon
      ln -s ${icon} $out/share/icons/hicolor/scalable/apps/ccleste.svg

      runHook postInstall
    '';

  meta = with lib; {
    description = "Celeste Classic C source port";
    homepage = "https://github.com/LonkToThePast/ccleste";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
