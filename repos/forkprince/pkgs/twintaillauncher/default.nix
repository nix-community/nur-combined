{
  libayatana-appindicator,
  libappindicator-gtk3,
  autoPatchelfHook,
  webkitgtk_4_1,
  makeWrapper,
  gdk-pixbuf,
  gamemode,
  fetchurl,
  mangohud,
  stdenv,
  cairo,
  pango,
  dpkg,
  glib,
  gtk3,
  lib,
}:
let
  ver = lib.helper.read ./version.json;
  platform = stdenv.hostPlatform.system;
in
stdenv.mkDerivation {
  pname = "twintaillauncher";
  inherit (ver) version;

  src = fetchurl (lib.helper.getPlatform platform ver);

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    dpkg
  ];

  buildInputs = [
    libayatana-appindicator
    libappindicator-gtk3
    webkitgtk_4_1
    gdk-pixbuf
    mangohud
    gamemode
    cairo
    pango
    glib
    gtk3
  ];

  unpackPhase = ''
    runHook preUnpack

    dpkg-deb -x $src .

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out

    cp -r usr/* $out/

    chmod +x \
      $out/bin/twintaillauncher \
      $out/lib/twintaillauncher/resources/reaper \
      $out/lib/twintaillauncher/resources/winetricks

    wrapProgram $out/bin/twintaillauncher \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          libayatana-appindicator
          libappindicator-gtk3
          webkitgtk_4_1
          gdk-pixbuf
          mangohud
          gamemode
          cairo
          pango
          glib
          gtk3
        ]
      }

    runHook postInstall
  '';

  meta = {
    description = "A multi-platform launcher for your anime games";
    homepage = "https://github.com/TwintailTeam/TwintailLauncher";
    maintainers = with lib.maintainers; [Prinky];
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    mainProgram = "twintaillauncher";
  };
}
