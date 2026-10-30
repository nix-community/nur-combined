{
  desktop-file-utils,
  autoPatchelfHook,
  wrapGAppsHook3,
  libpulseaudio,
  vulkan-loader,
  libxcomposite,
  libxshmfence,
  libxkbcommon,
  makeWrapper,
  at-spi2-atk,
  stdenvNoCC,
  gdk-pixbuf,
  libxdamage,
  libxkbfile,
  libnotify,
  libxfixes,
  libsecret,
  libxrandr,
  xdg-utils,
  fetchurl,
  alsa-lib,
  pipewire,
  pciutils,
  libxext,
  systemd,
  stdenv,
  ffmpeg,
  libgbm,
  libdrm,
  libx11,
  libxcb,
  yt-dlp,
  unzip,
  cairo,
  libGL,
  expat,
  pango,
  dpkg,
  cups,
  dbus,
  glib,
  gtk3,
  gtk4,
  nspr,
  lib,
  nss,
}: let
  ver = lib.helper.read ./version.json;

  pname = "opentubex";
  inherit (ver) version;
  src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);

  meta = {
    description = "Highly customizable, open-source YouTube client with privacy in mind";
    homepage = "https://opentubex.org";
    license = lib.licenses.agpl3Plus;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    maintainers = with lib.maintainers; [Prinky];
    mainProgram = "opentubex";
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
in
  if stdenvNoCC.hostPlatform.isDarwin
  then
    stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
      inherit pname version src meta;

      nativeBuildInputs = [unzip];
    })
  else
    stdenv.mkDerivation rec {
      inherit pname version src meta;

      strictDeps = true;
      dontBuild = true;
      dontConfigure = true;
      dontStrip = true;
      dontWrapGApps = true;

      nativeBuildInputs = [
        desktop-file-utils
        autoPatchelfHook
        wrapGAppsHook3
        makeWrapper
        dpkg
      ];

      buildInputs = [
        libxcomposite
        libpulseaudio
        vulkan-loader
        stdenv.cc.cc
        libxkbcommon
        libxshmfence
        at-spi2-atk
        gdk-pixbuf
        libxdamage
        libxkbfile
        libxfixes
        libxrandr
        libnotify
        libsecret
        alsa-lib
        pciutils
        pipewire
        libxext
        systemd
        libxcb
        libx11
        libgbm
        libdrm
        cairo
        expat
        pango
        libGL
        cups
        dbus
        glib
        gtk3
        gtk4
        nspr
        nss
      ];

      unpackPhase = ''
        runHook preUnpack

        dpkg-deb -x "$src" .

        runHook postUnpack
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p $out/bin $out/lib/opentubex $out/share

        cp -a opt/OpenTubeX/. $out/lib/opentubex/

        cp -a usr/share/applications usr/share/icons $out/share/

        substituteInPlace $out/share/applications/opentubex.desktop \
          --replace-fail /opt/OpenTubeX/opentubex $out/bin/opentubex

        rm $out/lib/opentubex/chrome-sandbox

        runHook postInstall
      '';

      preFixup = ''
        makeWrapper $out/lib/opentubex/opentubex $out/bin/opentubex \
          "''${gappsWrapperArgs[@]}" \
          --prefix PATH : ${lib.makeBinPath [xdg-utils ffmpeg yt-dlp]} \
          --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}
      '';

      doInstallCheck = true;
      installCheckPhase = ''
        runHook preInstallCheck

        test -x $out/bin/opentubex
        test -s $out/lib/opentubex/resources/app.asar
        desktop-file-validate $out/share/applications/opentubex.desktop

        runHook postInstallCheck
      '';
    }
