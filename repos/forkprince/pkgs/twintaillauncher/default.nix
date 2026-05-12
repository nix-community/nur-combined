{
  gsettings-desktop-schemas,
  libayatana-appindicator,
  libappindicator-gtk3,
  autoPatchelfHook,
  wrapGAppsHook3,
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
    wrapGAppsHook3
    makeWrapper
    dpkg
  ];

  buildInputs = [
    gsettings-desktop-schemas
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
      } \
      --prefix XDG_DATA_DIRS : "${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}" \
      --prefix GIO_EXTRA_MODULES : "${glib.out}/lib/gio/modules"

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
