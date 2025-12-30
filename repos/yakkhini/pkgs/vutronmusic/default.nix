{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  wrapGAppsHook3,
  dpkg,
  alsa-lib,
  libgcc,
  libxcb,
  libgbm,
  libxkbcommon,
  libdrm,
  libnotify,
  libsecret,
  libuuid,
  nss,
  nspr,
  mesa,
  udev,
  gtk3,
  x11basic,
}: let
  pname = "vutronmusic";
  version = "2.9.0";

  srcs = {
    x86_64-linux = fetchurl {
      url = "https://github.com/stark81/VutronMusic/releases/download/v${version}/VutronMusic-${version}_linux_amd64.deb";
      hash = "sha256-jfWIBLFpTglrT6LOOVsGlCePykDO2JlbrvQfgQ7nxR0=";
    };
    # aarch64-linux = fetchurl {
    #   url = "https://github.com/stark81/VutronMusic/releases/download/v${version}/yesplaymusic_${version'}_arm64.deb";
    #   hash = "sha256-PP0apybSORqleOBogldgIV1tYZqao8kZ474muAEDpd0";
    # };
    # x86_64-darwin = fetchurl {
    #   url = "https://github.com/stark81/VutronMusic/releases/download/v${version}/VutronMusic-mac-${version'}-x64.dmg";
    #   hash = "sha256-UHnEdoXT/vArSRKXPlfDYUUUMDyF2mnDsmJEjACW2vo=";
    # };
    # aarch64-darwin = fetchurl {
    #   url = "https://github.com/stark81/VutronMusic/releases/download/v${version}/VutronMusic-mac-${version'}-arm64.dmg";
    #   hash = "sha256-FaeumNmkPQYj9Ae2Xw/eKUuezR4bEdni8li+NRU9i1k=";
    # };
  };
  src =
    srcs.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  libraries = [
    alsa-lib
    libgcc.lib
    libxcb
    libgbm
    libxkbcommon
    libdrm
    libnotify
    libsecret
    libuuid
    nss
    nspr
    mesa
    udev
    gtk3
    x11basic
  ];

  meta = with lib; {
    description = "Good-looking third-party netease cloud music player";
    mainProgram = "vutron";
    homepage = "https://github.com/stark81/VutronMusic/";
    downloadPage = "https://github.com/stark81/VutronMusic/releases";
    license = licenses.mit;
    sourceProvenance = with sourceTypes; [binaryNativeCode];
    platforms = builtins.attrNames srcs;
  };
in
  if stdenv.hostPlatform.isDarwin
  then
    stdenv.mkDerivation {
      inherit
        pname
        version
        src
        meta
        ;

      nativeBuildInputs = [
      ];

      sourceRoot = ".";

      installPhase = ''
        runHook preInstall

        # mkdir -p $out/Applications
        # cp -r *.app $out/Applications
        #
        # makeWrapper $out/Applications/VutronMusic.app/Contents/MacOS/VutronMusic $out/bin/yesplaymusic
        #
        runHook postInstall
      '';
    }
  else
    stdenv.mkDerivation {
      inherit
        pname
        version
        src
        meta
        ;

      nativeBuildInputs = [
        autoPatchelfHook
        makeWrapper
        wrapGAppsHook3
        dpkg
      ];

      autoPatchelfIgnoreMissingDeps = [
        "libc.musl-x86_64.so.1"
      ];

      buildInputs = libraries;

      # runtimeDependencies = [
      #   (lib.getLib systemd)
      # ];

      installPhase = ''
        runHook preInstall

        mkdir -p $out/bin
        cp -r opt $out/opt
        cp -r usr/share $out/share
        substituteInPlace $out/share/applications/vutron.desktop \
          --replace-warn "/opt/VutronMusic/vutron" "$out/bin/vutron"
        makeWrapper $out/opt/VutronMusic/vutron $out/bin/vutron \
          --argv0 "vutron" \
          --add-flags "$out/opt/VutronMusic/resources/app.asar" \
          --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath libraries}"

        runHook postInstall
      '';
    }
