{
  libayatana-appindicator,
  autoPatchelfHook,
  copyDesktopItems,
  makeDesktopItem,
  libXcomposite,
  libxkbcommon,
  at-spi2-core,
  at-spi2-atk,
  makeWrapper,
  stdenvNoCC,
  keybinder3,
  fontconfig,
  gdk-pixbuf,
  libXcursor,
  libXdamage,
  libXrender,
  libnotify,
  libXfixes,
  libXrandr,
  fetchurl,
  alsa-lib,
  freetype,
  harfbuzz,
  libepoxy,
  libuuid,
  systemd,
  wayland,
  libXext,
  libXtst,
  libdrm,
  libpng,
  libX11,
  libxcb,
  cairo,
  expat,
  libGL,
  pango,
  libXi,
  _7zz,
  dbus,
  glib,
  gtk3,
  mesa,
  nspr,
  zlib,
  nss,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  pname = "brisk";
  inherit (ver) version;

  src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);

  meta = {
    description = "Ultra-fast, modern download manager for desktop";
    homepage = "https://github.com/BrisklyDev/brisk";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [Prinky];
    platforms = lib.platforms.darwin ++ ["x86_64-linux"];
    mainProgram = "brisk";
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
in
  if stdenvNoCC.hostPlatform.isDarwin
  then
    stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
      inherit pname version src meta;

      nativeBuildInputs = [_7zz];
    })
  else let
    buildInputs = [
      libayatana-appindicator
      libXcomposite
      at-spi2-core
      libxkbcommon
      at-spi2-atk
      fontconfig
      gdk-pixbuf
      keybinder3
      libXcursor
      libXdamage
      libXrender
      libnotify
      libXfixes
      libXrandr
      alsa-lib
      freetype
      harfbuzz
      libepoxy
      libuuid
      libXext
      libXtst
      systemd
      wayland
      libdrm
      libpng
      libxcb
      libX11
      cairo
      expat
      libGL
      libXi
      pango
      dbus
      glib
      gtk3
      mesa
      nspr
      zlib
      nss
    ];
  in
    stdenvNoCC.mkDerivation {
      inherit pname version src meta buildInputs;

      nativeBuildInputs = [
        autoPatchelfHook
        copyDesktopItems
        makeWrapper
      ];

      sourceRoot = ".";

      installPhase = ''
        runHook preInstall

        mkdir -p $out/share/brisk $out/bin
        cp -r ./* $out/share/brisk/

        chmod +x $out/share/brisk/brisk

        makeWrapper $out/share/brisk/brisk $out/bin/brisk \
          --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}"

        install -Dm644 $out/share/brisk/data/flutter_assets/assets/icons/logo.png \
          $out/share/icons/hicolor/512x512/apps/brisk.png

        runHook postInstall
      '';

      desktopItems = [
        (makeDesktopItem {
          name = "brisk";
          desktopName = "Brisk";
          exec = "brisk %U";
          icon = "brisk";
          comment = "Ultra-fast, modern download manager for desktop";
          categories = ["Network" "Utility"];
          startupWMClass = "brisk";
        })
      ];
    }
