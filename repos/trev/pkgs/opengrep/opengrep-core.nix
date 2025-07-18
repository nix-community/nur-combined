{
  system,
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}: let
  common = import ./common.nix {inherit lib;};
  binaries = {
    aarch64-linux = fetchurl {
      url = "https://github.com/spotdemo4/opengrep/releases/download/v${common.version}/opengrep-core_linux_aarch64.tar.gz";
      hash = "sha256-jy+6tpey5+IVRR2GJ9h6QCE7in2e+hGPaEcxH+C1Iz8=";
    };
    x86_64-linux = fetchurl {
      url = "https://github.com/spotdemo4/opengrep/releases/download/v${common.version}/opengrep-core_linux_x86.tar.gz";
      hash = "sha256-1YVEIPXLpdLg6r8rWMQH7Lp6OTJ22LjpnS6pgOTwS7E=";
    };
    aarch64-darwin = fetchurl {
      url = "https://github.com/spotdemo4/opengrep/releases/download/v${common.version}/opengrep-core_osx_aarch64.tar.gz";
      hash = "sha256-n5A93MyKpjIzF0ejCZ/oDwn+EKl/oROrt4Fe3CJMwDI=";
    };
    x86_64-darwin = fetchurl {
      url = "https://github.com/spotdemo4/opengrep/releases/download/v${common.version}/opengrep-core_osx_x86.tar.gz";
      hash = "sha256-n6+7wHsgqqhgsQDaWL8umAQ8KJ0AdlvMIfK567lsoHY=";
    };
  };
in
  stdenv.mkDerivation {
    pname = "opengrep-core";
    inherit (common) version;

    src = binaries."${system}";

    nativeBuildInputs = [
      autoPatchelfHook
    ];

    sourceRoot = ".";

    installPhase = ''
      runHook preInstall
      install -m755 -D opengrep-core $out/bin/opengrep-core
      runHook postInstall
    '';

    meta =
      common.meta
      // {
        description = common.meta.description + " - core binary";
        mainProgram = "opengrep-core";
        sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
        platforms = lib.attrNames binaries;
      };
  }
