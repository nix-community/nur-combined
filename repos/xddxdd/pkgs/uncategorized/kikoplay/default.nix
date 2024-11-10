{
  stdenv,
  sources,
  lib,
  callPackage,
  libsForQt5,
  makeWrapper,
  qt5,
  mpv,
  lua5_3_compat,
}:
let
  qhttpengine = callPackage ./qhttpengine.nix { inherit sources; };
in
stdenv.mkDerivation rec {
  inherit (sources.kikoplay) pname version src;

  nativeBuildInputs = [
    libsForQt5.qmake
    qt5.wrapQtAppsHook
    makeWrapper
  ];

  buildInputs = [
    qt5.qtbase
    qt5.qtwebsockets
    mpv
    qhttpengine
  ];

  patches = [ ./change-install-path.patch ];

  postPatch = ''
    sed -i "s|OUTPATH|$out|g" KikoPlay.pro
    sed -i "s|liblua53.a|${lua5_3_compat}/lib/liblua.so.5.3|g" KikoPlay.pro

    sed -i "s|/usr/share/pixmaps/kikoplay.png|$out/share/pixmaps/kikoplay.png|g" kikoplay.desktop
    sed -i "s|/usr/share/kikoplay/|$out/share/kikoplay/|g" \
      Extension/App/appmanager.cpp \
      Extension/Script/scriptmanager.cpp \
      LANServer/router.cpp
  '';

  qmakeFlags = [ "KikoPlay.pro" ];
  hardeningDisable = [ "format" ];

  # We will append QT wrapper args to our own wrapper
  dontWrapQtApps = true;

  postFixup = ''
    mkdir -p $out/share/kikoplay/extension/script
    cp -r ${sources.kikoplay-script.src}/{bgm_calendar,danmu,library,resource} $out/share/kikoplay/extension/script/
    mkdir -p $out/share/kikoplay/extension/app
    cp -r ${sources.kikoplay-app.src}/app/* $out/share/kikoplay/extension/app/

    wrapProgram $out/bin/KikoPlay \
      "''${qtWrapperArgs[@]}" \
      --set QT_QPA_PLATFORM xcb \
      --set XDG_SESSION_TYPE x11
  '';

  meta = {
    mainProgram = "KikoPlay";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "KikoPlay - NOT ONLY A Full-Featured Danmu Player";
    homepage = "https://kikoplay.fun";
    license = lib.licenses.gpl3Only;
  };
}
