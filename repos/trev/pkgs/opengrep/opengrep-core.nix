{
  system,
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}: let
  common = import ./common.nix {inherit lib;};
  binaries = {
    x86_64-linux = fetchurl {
      url = "https://github.com/spotdemo4/opengrep/releases/download/v1.6.0/opengrep-core_linux_x86_64.tar.gz";
      hash = "sha256:487d3626bd4eedbfa7260ba4268b271b4e2aae8e3ccdb15aa298176bc869e2f5";
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
      };
  }
