# Originally from https://github.com/NixOS/nixpkgs/pull/479368, via gepbird's NUR package.
# The launcher is unpatched, so Linux runs it inside an FHS environment that provides its runtime libraries.
{
  copyDesktopItems,
  makeDesktopItem,
  buildFHSEnv,
  stdenvNoCC,
  fetchurl,
  unzip,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  pname = "hytale-launcher";
  inherit (ver) version;

  src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);

  meta = {
    description = "Official launcher for Hytale";
    homepage = "https://hytale.com";
    license = lib.licenses.unfreeRedistributable;
    maintainers = with lib.maintainers; [Prinky gepbird];
    mainProgram = pname;
    platforms = lib.platforms.darwin ++ ["x86_64-linux"];
    sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
  };
in
  if stdenvNoCC.hostPlatform.isDarwin
  then
    stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
      inherit pname version src meta;

      nativeBuildInputs = [unzip];

      unpackPhase = ''
        runHook preUnpack
        LANG=C.UTF-8 unzip -qq "$src" || [ $? -eq 1 ]
        runHook postUnpack
      '';
    })
  else let
    unwrapped = stdenvNoCC.mkDerivation {
      pname = "${pname}-unwrapped";
      inherit version src;

      sourceRoot = ".";

      nativeBuildInputs = [
        copyDesktopItems
        unzip
      ];

      unpackCmd = ''
        LANG=C.UTF-8 unzip -qq "$curSrc" || [ $? -eq 1 ]
      '';

      desktopItems = [
        (makeDesktopItem {
          name = "com.hypixel.HytaleLauncher";
          exec = "hytale-launcher";
          desktopName = "Hytale Launcher";
          comment = "Official launcher for Hytale";
          icon = "com.hypixel.HytaleLauncher";
          categories = ["Game"];
          terminal = false;
          startupWMClass = "com.hypixel.HytaleLauncher";
        })
      ];

      dontBuild = true;
      dontStrip = true;

      installPhase = ''
        runHook preInstall

        install -Dm755 hytale-launcher $out/bin/hytale-launcher

        mkdir -p $out/share/icons
        cp -r ${./icons}/hicolor $out/share/icons/

        runHook postInstall
      '';

      inherit meta;
    };
  in
    buildFHSEnv {
      inherit pname version;

      targetPkgs = pkgs: (with pkgs; [
        webkitgtk_4_1
        libpulseaudio
        libxkbcommon
        libXinerama
        gdk-pixbuf
        libXcursor
        libXxf86vm
        unwrapped
        libsecret
        libsoup_3
        xdg-utils
        libXrandr
        libglvnd
        libdecor
        alsa-lib
        openssl
        libXext
        wayland
        libdrm
        libX11
        libXi
        gtk3
        glib
        mesa
        SDL2
        nss
        icu
      ]);

      profile = ''
        export WEBKIT_DISABLE_DMABUF_RENDERER=1
        export __NV_DISABLE_EXPLICIT_SYNC=1
      '';

      runScript = "hytale-launcher";

      extraInstallCommands = ''
        mkdir -p $out/share/applications $out/share/icons
        ln -s ${unwrapped}/share/applications/com.hypixel.HytaleLauncher.desktop $out/share/applications/
        ln -s ${unwrapped}/share/icons/hicolor $out/share/icons/
      '';

      inherit meta;
    }
