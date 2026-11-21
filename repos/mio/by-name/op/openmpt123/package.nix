{
  lib,
  stdenv,
  pkgs,
  pkgsCross,
  wineWow64Packages,
  gcenx-wine-staging,
  writeShellApplication,
}:

let
  isDarwin = stdenv.hostPlatform.isDarwin;

  wine = if isDarwin then gcenx-wine-staging else wineWow64Packages.full;

  pname = "openmpt123";
  version = "0.8.10";

  openmpt123Windows = pkgs.callPackage ./windows.nix { inherit pkgsCross; };

  meta = with lib; {
    mainProgram = pname;
    homepage = "https://lib.openmpt.org/libopenmpt/";
    description = "openmpt123 module player (MinGW cross build, run with Wine)";
    longDescription = ''
      The official command-line module player from the OpenMPT project,
      cross-compiled for Windows with MinGW-w64 and run through Wine. The
      OpenMPT tracker itself is MFC-based and MSVC-only, so it cannot be built
      this way. On macOS this uses gcenx-wine-staging instead of nixpkgs Wine.
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
  # No prefix install: openmpt123.exe is self-contained and only reads the
  # module files it is given. Wine translates the Unix arguments itself, and
  # wine64 is preferred the same way mkWindowsApp's launcher picks it.
  text = ''
    set -euo pipefail
    WINE="${wine}/bin/wine64"
    if [ ! -e "$WINE" ]; then
      WINE="${wine}/bin/wine"
    fi
    exec "$WINE" ${openmpt123Windows}/share/openmpt123/openmpt123.exe "$@"
  '';
}
