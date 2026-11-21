{
  lib,
  stdenv,
  pkgs,
  wineWow64Packages,
  gcenx-wine-staging,
  writeShellApplication,
  msvc-wine-toolchain,
}:

let
  isDarwin = stdenv.hostPlatform.isDarwin;

  wine = if isDarwin then gcenx-wine-staging else wineWow64Packages.full;

  pname = "openmpt-tracker";
  version = "0.8.10";

  # The MSVC toolchain is a package of this repository, not of nixpkgs, so it
  # has to be handed to the nested callPackage explicitly.
  openmptWindows = pkgs.callPackage ./windows.nix {
    inherit wine msvc-wine-toolchain;
  };

  meta = with lib; {
    mainProgram = pname;
    homepage = "https://openmpt.org/";
    description = "OpenMPT tracker (real MSVC + MFC build, run with Wine)";
    longDescription = ''
      Builds the OpenMPT tracker GUI from the source that libopenmpt ships,
      using Microsoft's own cl.exe, lib.exe, link.exe and rc.exe with ATL/MFC
      under Wine — the build system MSVC-only MFC code requires. The GUI is
      launched with Wine; openmpt123 (the command line player) is available
      separately as a MinGW build.
    '';
    license = licenses.bsd3;
    maintainers = [ "maydayv7" ];
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
  };
in
writeShellApplication {
  name = pname;
  runtimeInputs = [ wine ];
  inherit meta;
  passthru.updateScript = ./update.sh;

  # The payload is self-contained apart from its own mpg123/lame DLLs, which
  # sit next to the exe, so the prefix only has to exist; settings go to
  # %APPDATA% inside it.
  text = ''
    set -euo pipefail
    export WINEPREFIX="''${OPENMPT_WINEPREFIX:-''${XDG_DATA_HOME:-$HOME/.local/share}/${pname}/wineprefix}"
    WINE="${wine}/bin/wine64"
    if [ ! -e "$WINE" ]; then
      WINE="${wine}/bin/wine"
    fi
    if [ ! -d "$WINEPREFIX" ]; then
      mkdir -p "$WINEPREFIX"
      "$WINE" boot --init || true
      wineserver -w || true
    fi
    exec "$WINE" ${openmptWindows}/share/openmpt-tracker/OpenMPT.exe "$@"
  '';
}
