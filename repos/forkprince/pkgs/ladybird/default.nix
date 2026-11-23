{
  libxcb-render-util,
  autoPatchelfHook,
  libxcb-keysyms,
  vulkan-loader,
  libpulseaudio,
  libxcb-cursor,
  libunistring,
  libxkbcommon,
  libxcb-image,
  makeWrapper,
  libxcb-util,
  stdenvNoCC,
  libxcb-wm,
  libdwarf,
  fetchurl,
  libidn2,
  wayland,
  libdrm,
  libx11,
  libxcb,
  icu78,
  libGL,
  dpkg,
  dbus,
  glib,
  _7zz,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  pname = "ladybird";

  inherit (ver) version;

  meta = {
    description = "Independent web browser using a novel engine based on web standards";
    homepage = "https://ladybird.org";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [Prinky];
    platforms = lib.platforms.darwin ++ ["x86_64-linux"];
    mainProgram = pname;
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
in
  if stdenvNoCC.hostPlatform.isDarwin
  then
    stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
      inherit pname version meta;

      src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);

      nativeBuildInputs = [_7zz];

      postFixup = ''
        mkdir -p $out/bin
        ln -s $out/Applications/Ladybird.app/Contents/MacOS/Ladybird $out/bin/${pname}
      '';
    })
  else
    stdenvNoCC.mkDerivation rec {
      inherit pname version meta;

      src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);

      nativeBuildInputs = [
        autoPatchelfHook
        makeWrapper
        dpkg
      ];

      buildInputs = [
        libxcb-render-util
        libxcb-keysyms
        libpulseaudio
        libxcb-cursor
        vulkan-loader
        libunistring
        libxkbcommon
        libxcb-image
        libxcb-util
        libxcb-wm
        libdwarf
        libidn2
        wayland
        libdrm
        libx11
        libxcb
        libGL
        icu78
        dbus
        glib
      ];

      sourceRoot = ".";

      autoPatchelfIgnoreMissingDeps = [
        "libGLES_CM.so.1"
        "libsteam_api.so"
      ];

      unpackPhase = ''
        runHook preUnpack

        dpkg-deb --fsys-tarfile $src | tar -x --no-same-owner --no-same-permissions

        runHook postUnpack
      '';

      dontBuild = true;
      dontConfigure = true;

      installPhase = ''
        runHook preInstall

        mkdir -p $out/opt
        cp -r opt/ladybird $out/opt/ladybird
        chmod -R u+w $out/opt/ladybird

        mkdir -p $out/bin
        makeWrapper $out/opt/ladybird/bin/Ladybird $out/bin/${pname} \
          --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}" \
          --suffix QT_PLUGIN_PATH : "$out/opt/ladybird/Qt6/plugins"

        mkdir -p $out/share/applications $out/share/icons/hicolor/scalable/apps \
          $out/share/metainfo $out/share/dbus-1/services

        substitute usr/share/applications/org.ladybird.Ladybird.desktop \
          $out/share/applications/org.ladybird.Ladybird.desktop \
          --replace-fail "/opt/ladybird/bin/Ladybird" "$out/bin/${pname}"

        substitute usr/share/dbus-1/services/org.ladybird.Ladybird.service \
          $out/share/dbus-1/services/org.ladybird.Ladybird.service \
          --replace-fail "/opt/ladybird/bin/Ladybird" "$out/bin/${pname}"

        install -Dm644 usr/share/icons/hicolor/scalable/apps/org.ladybird.Ladybird.svg \
          $out/share/icons/hicolor/scalable/apps/org.ladybird.Ladybird.svg

        install -Dm644 usr/share/metainfo/org.ladybird.Ladybird.metainfo.xml \
          $out/share/metainfo/org.ladybird.Ladybird.metainfo.xml

        runHook postInstall
      '';
    }
