{
  lib,
  stdenv,
  fetchurl,
  pkg-config,
  SDL2,
  SDL2_mixer,
  makeDesktopItem,
  copyDesktopItems,
}:

stdenv.mkDerivation rec {
  pname = "ccleste";
  version = "1.4.0";

  src = fetchurl {
    url = "https://github.com/lemon32767/ccleste/archive/refs/tags/v${version}.tar.gz";
    sha256 = "sha256-Mt/Xl/PIYyAeDBmql5dMVqjtWJo0wFIlA/JfbhOZ7dY=";
  };

  nativeBuildInputs = [
    pkg-config
    copyDesktopItems
  ];

  buildInputs = [
    SDL2
    SDL2_mixer
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
    ./fix-pitch.patch
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
      cp ccleste $out/bin/
      cp -r data $out/share/ccleste/

      # Install icon
      ln -s ${icon} $out/share/icons/hicolor/scalable/apps/ccleste.svg

      runHook postInstall
    '';

  meta = with lib; {
    description = "Celeste Classic C source port";
    homepage = "https://github.com/lemon32767/ccleste";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
