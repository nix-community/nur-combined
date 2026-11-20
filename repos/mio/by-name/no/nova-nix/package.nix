{
  lib,
  stdenv,
  fetchzip,
  writeShellApplication,
  wineWow64Packages,
  coreutils,
  winePackage ? wineWow64Packages.full,
}:

let
  pname = "nova-nix";
  version = "0.10.0.0";

  src = fetchzip {
    url = "https://github.com/Novavero-AI/nova-nix/releases/download/v${version}/nova-nix-windows-x64.zip";
    hash = "sha256-jipUW/jHILNzv1k0+qMIJsjs/wgQ9PerOoBQS71wi5A=";
  };

  launcher = writeShellApplication {
    name = pname;
    runtimeInputs = [
      winePackage
      coreutils
    ];
    text = ''
      set -euo pipefail

      dir="''${NOVA_NIX_WINEPREFIX:-''${XDG_DATA_HOME:-$HOME/.local/share}/nova-nix/wineprefix}"
      export WINEPREFIX="$dir"
      mkdir -p "$dir"

      # nova-nix's default store is C:\nix\store, which Wine maps to
      # $WINEPREFIX/drive_c/nix/store. Wine creates the prefix on first run.
      exec wine "@out@/share/nova-nix/bin/nova-nix.exe" "$@"
    '';
  };
in
stdenv.mkDerivation {
  inherit pname version;

  inherit src;

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/nova-nix $out/bin
    cp -r ${src}/. $out/share/nova-nix/
    substitute ${launcher}/bin/${pname} $out/bin/${pname} \
      --subst-var out
    chmod +x $out/bin/${pname}

    runHook postInstall
  '';

  passthru = {
    wine = winePackage;
    updateScript = ./update.sh;
  };

  meta = with lib; {
    description = "Nix implementation for Windows (experimental), packaged to run under Wine";
    homepage = "https://github.com/Novavero-AI/nova-nix";
    license = licenses.asl20;
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = pname;
  };
}
