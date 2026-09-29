{
  autoPatchelfHook,
  libxkbcommon,
  makeWrapper,
  stdenvNoCC,
  fontconfig,
  libxrender,
  fetchurl,
  alsa-lib,
  freetype,
  wayland,
  libxext,
  libxtst,
  libx11,
  stdenv,
  unzip,
  libxi,
  libGL,
  zlib,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  pname = "blip";
  inherit (ver) version;

  src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);

  meta = {
    description = "Send any size file between devices";
    homepage = "https://blip.net/";
    maintainers = with lib.maintainers; [Prinky];
    license = lib.licenses.unfree;
    platforms = lib.platforms.darwin ++ lib.platforms.linux;
    mainProgram = "blip";
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
    # Based on/taken from https://github.com/blip-net/nix (the official flake)
    stdenv.mkDerivation rec {
      inherit pname version src meta;

      nativeBuildInputs = [
        autoPatchelfHook
        makeWrapper
      ];

      # Native libraries needed by ELF binaries and by JNA at runtime.
      # Must be buildInputs (not runtimeDependencies): autoPatchelfHook needs the
      # .so files inside the build sandbox to resolve and embed their store paths.
      buildInputs = [
        stdenv.cc.cc.lib # libstdc++.so.6
        libxkbcommon
        fontconfig
        libxrender
        freetype
        alsa-lib
        wayland # libwayland-client.so.0, libwayland-cursor.so.0
        libxtst
        libxext
        libx11
        libGL
        libxi
        zlib
      ];

      dontBuild = true;

      installPhase = ''
        runHook preInstall

        install -d $out/opt/blip
        cp -r bin lib $out/opt/blip/

        install -d $out/bin
        ln -s $out/opt/blip/bin/blip $out/bin/blip

        cp -r share $out/

        runHook postInstall
      '';

      # Expose the bundled JBR lib dirs to autoPatchelfHook so it can resolve
      # libjvm.so before the fixup phase.
      #
      # autoPatchelfHook sets DT_RUNPATH (not DT_RPATH), which is not inherited
      # by dlopen() calls made from loaded code. JNA uses dlopen() directly, so
      # LD_LIBRARY_PATH is wrapped in as well.
      postInstall = ''
        addAutoPatchelfSearchPath "$out/opt/blip/lib/runtime/lib"
        addAutoPatchelfSearchPath "$out/opt/blip/lib/runtime/lib/server"

        wrapProgram $out/opt/blip/bin/blip \
          --set BLIP_LAUNCHER "$out/bin/blip" \
          --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}
      '';
    }
