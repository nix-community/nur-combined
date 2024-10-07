{
  source,
  lib,
  stdenv,
  audacious-plugins,
  meson,
  ninja,
  pkg-config,
  qtbase,
  qtsvg,
  qtwayland,
  wrapQtAppsHook,
  wrapGAppsHook,
}:

stdenv.mkDerivation {
  inherit (source) pname version src;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook
    wrapQtAppsHook
  ];

  buildInputs = [
    qtbase
    qtsvg
    qtwayland
  ];

  mesonFlags = [
    "-Dgtk=false"
    "-Dbuildstamp=NixOS"
  ];

  postInstall = lib.optionalString (audacious-plugins != null) ''
    ln -s ${audacious-plugins}/lib/audacious $out/lib
    ln -s ${audacious-plugins}/share/audacious/Skins $out/share/audacious/
  '';

  meta = {
    description = "Lightweight and versatile audio player";
    homepage = "https://audacious-media-player.org";
    downloadPage = "https://github.com/audacious-media-player/audacious";
    mainProgram = "audacious";
    maintainers = with lib.maintainers; [
      eelco
      ramkromberg
      ttuegel
      thiagokokada
    ];
    platforms = lib.platforms.linux;
    license = with lib.licenses; [
      bsd2
      bsd3 # https://github.com/audacious-media-player/audacious/blob/master/COPYING
      gpl2
      gpl3
      lgpl2Plus # http://redmine.audacious-media-player.org/issues/46
    ];
  };
}
