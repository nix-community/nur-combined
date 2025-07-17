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
      hash = "sha256:80d2d31fc894b45aba907b172ac4267ae4e5ee0a994eeda5048e29d8a999fcfa";
    };
    x86_64-linux = fetchurl {
      url = "https://github.com/spotdemo4/opengrep/releases/download/v${common.version}/opengrep-core_linux_x86.tar.gz";
      hash = "sha256-tBQwa2uIEA9xu0kp+Dok8tqdticLrwuRBCDhqvc6cTI=";
    };
    aarch64-darwin = fetchurl {
      url = "https://github.com/spotdemo4/opengrep/releases/download/v${common.version}/opengrep-core_osx_aarch64.tar.gz";
      hash = "sha256:a64c8da6b0ad0de64e4875abbafb893425f109023de38257de099889fca395d9";
    };
    x86_64-darwin = fetchurl {
      url = "https://github.com/spotdemo4/opengrep/releases/download/v${common.version}/opengrep-core_osx_x86.tar.gz";
      hash = "sha256:1871b6bd609d69a903b04a1b0294d9a6cd96f723f53eaab77bcff19494033b55";
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
