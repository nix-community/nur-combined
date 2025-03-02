{
  lib,
  pkgs,
}: let
  meshroom-unwrapped = pkgs.stdenv.mkDerivation rec {
    pname = "meshroom-unwrapped";
    version = "2023.3.0";

    src = pkgs.fetchurl {
      url = "https://github.com/alicevision/Meshroom/releases/download/v${version}/Meshroom-${version}-linux.tar.gz";
      hash = "sha256-krgSRjVt8/036gjh0JUZOSiXqqcwhD65/UvQWCkW05E=";
    };

    nativeBuildInputs = with pkgs; [
      libsForQt5.wrapQtAppsHook
    ];

    sourceRoot = ".";

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp -r Meshroom-2023.3.0/* $out/bin/
      runHook postInstall
      runHook preFixup
    '';

    meta = with lib; {
      homepage = "https://alicevision.org/#meshroom";
      description = "Meshroom";
      platforms = platforms.linux;
    };
  };
in
  pkgs.buildFHSEnv {
    name = "meshroom";

    targetPkgs = pkgs:
      with pkgs; [
        krb5.lib
        e2fsprogs
        libGL
        at-spi2-atk
        pango
        gdk-pixbuf
        libpulseaudio
        libsForQt5.full
        speechd
        gtk3
        unixODBC
        postgresql.lib
        meshroom-unwrapped
      ];

    runScript = "${meshroom-unwrapped}/bin/Meshroom";
  }
