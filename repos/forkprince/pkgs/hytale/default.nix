# NOTE
# this was taken from https://github.com/NixOS/nixpkgs/pull/479368, credits to all people involved
# converting to buildFHSEnv was done by AI, needs cleanup
#
# then I (prinky) took this from https://github.com/nix-community/nur-combined/blob/main/repos/gepbird/pkgs/hytale-launcher/default.nix#L95
# and added auto updating
{
  lib,
  stdenv,
  fetchurl,
  unzip,
  buildFHSEnv,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
  gtk3,
  nss,
  libsecret,
  libsoup_3,
  gdk-pixbuf,
  glib,
  webkitgtk_4_1,
  xdg-utils,
  openssl,
  SDL2,
  xorg,
  wayland,
  libxkbcommon,
  libdecor,
  alsa-lib,
  libpulseaudio,
}: let
  ver = lib.helper.read ./version.json;
  platform = stdenv.hostPlatform.system;
  src = fetchurl (lib.helper.getPlatform platform ver);
  inherit (ver) version;

  pname = "hytale-launcher";

  unwrapped = stdenv.mkDerivation {
    pname = "${pname}-unwrapped";
    inherit version src;

    sourceRoot = ".";

    nativeBuildInputs =
      [
        makeWrapper
        unzip
      ]
      ++ lib.optionals stdenv.hostPlatform.isLinux [
        copyDesktopItems
      ];

    desktopItems = lib.optionals stdenv.hostPlatform.isLinux [
      (makeDesktopItem {
        name = "hytale-launcher";
        exec = "hytale-launcher";
        desktopName = "Hytale Launcher";
        categories = ["Game"];
        terminal = false;
      })
    ];

    dontBuild = true;
    dontFixup = stdenv.hostPlatform.isDarwin;
    dontStrip = true;

    installPhase =
      ''
        runHook preInstall
      ''
      + lib.optionalString stdenv.hostPlatform.isLinux ''
        mkdir -p "$out/bin"
        install -Dm755 "hytale-launcher" "$out/bin/hytale-launcher"
      ''
      + lib.optionalString stdenv.hostPlatform.isDarwin ''
        mkdir -p $out/Applications
        app=$(find . -maxdepth 2 -name "*.app" -type d | head -n1)
        cp -R "$app" $out/Applications/
      ''
      + ''
        runHook postInstall
      '';

    meta = {
      description = "Official launcher for Hytale";
      homepage = "https://hytale.com";
      license = lib.licenses.unfreeRedistributable;
      maintainers = with lib.maintainers; [gepbird];
      mainProgram = "hytale-launcher";
      platforms = [
        "x86_64-linux"
        "aarch64-darwin"
      ];
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
    };
  };
in
  if stdenv.hostPlatform.isLinux
  then
    buildFHSEnv {
      name = pname;
      inherit version;

      targetPkgs = pkgs: (with pkgs; [
        unwrapped
        gtk3
        nss
        libsecret
        libsoup_3
        gdk-pixbuf
        glib
        webkitgtk_4_1
        xdg-utils
        mesa
        libglvnd
        libdrm
        icu
        openssl
        SDL2
        xorg.libX11
        xorg.libXcursor
        xorg.libXrandr
        xorg.libXext
        xorg.libXi
        xorg.libXinerama
        xorg.libXxf86vm
        wayland
        libxkbcommon
        libdecor
        alsa-lib
        libpulseaudio
      ]);

      profile = ''
        export WEBKIT_DISABLE_DMABUF_RENDERER=1
        export __NV_DISABLE_EXPLICIT_SYNC=1
      '';

      runScript = "hytale-launcher";

      extraInstallCommands = ''
        mkdir -p "$out/share/applications"
        ln -s "${unwrapped}/share/applications/hytale-launcher.desktop" "$out/share/applications/"
      '';

      inherit (unwrapped) meta;
    }
  else unwrapped
