{
  autoPatchelfHook,
  copyDesktopItems,
  makeDesktopItem,
  libpulseaudio,
  vulkan-loader,
  libxkbcommon,
  makeWrapper,
  libXinerama,
  stdenvNoCC,
  fontconfig,
  libXcursor,
  libXrender,
  libXrandr,
  libunwind,
  libXfixes,
  alsa-lib,
  fetchurl,
  freetype,
  libXext,
  wayland,
  openssl,
  libX11,
  unzip,
  libGL,
  libXi,
  dbus,
  mesa,
  udev,
  zlib,
  icu,
  lib
}: let
  ver = lib.helper.read ./version.json;

  inherit (ver) version;

  src = fetchurl (lib.helper.getSingle ver);
in
  stdenvNoCC.mkDerivation rec {
    pname = "rhythia";
    inherit version src;

    sourceRoot = ".";
    dontBuild = true;
    dontStrip = true;

    nativeBuildInputs = [
      autoPatchelfHook
      copyDesktopItems
      makeWrapper
      unzip
    ];

    buildInputs = [
      vulkan-loader
      libpulseaudio
      libxkbcommon
      libXinerama
      libXrender
      libXcursor
      fontconfig
      libXrandr
      libunwind
      libXfixes
      alsa-lib
      freetype
      libXext
      openssl
      wayland
      libX11
      libGL
      libXi
      dbus
      mesa
      udev
      zlib
      icu
    ];

    autoPatchelfIgnoreMissingDeps = true;

    desktopItems = [
      (makeDesktopItem {
        name = pname;
        desktopName = "Rhythia";
        genericName = "Rhythm Game";
        comment = meta.description;
        exec = "${pname} %U";
        terminal = false;
        categories = ["Game"];
      })
    ];

    installPhase = ''
      runHook preInstall

      srcdir=$(find . -maxdepth 2 -name "Rhythia.x86_64" -exec dirname {} \; | head -n1)
      if [ -z "$srcdir" ]; then
        echo "Rhythia.x86_64 not found" >&2
        exit 1
      fi

      mkdir -p $out/share/${pname} $out/bin
      cp -r "$srcdir"/* $out/share/${pname}/
      chmod +x $out/share/${pname}/Rhythia.x86_64

      makeWrapper $out/share/${pname}/Rhythia.x86_64 $out/bin/${pname} \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}:$out/share/${pname}" \
        --chdir $out/share/${pname}

      runHook postInstall
    '';

    meta = {
      description = "Aim-based rhythm game client, built in Godot 4";
      homepage = "https://github.com/Rhythia/Client";
      changelog = "https://github.com/Rhythia/Client/releases/tag/${version}";
      license = lib.licenses.agpl3Only;
      platforms = ["x86_64-linux"];
      maintainers = with lib.maintainers; [Prinky];
      mainProgram = pname;
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  }
