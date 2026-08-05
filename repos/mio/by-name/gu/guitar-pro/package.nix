{
  lib,
  stdenv,
  pkgs,
  wineWow64Packages,
  gcenx-wine-staging,
  copyDesktopItems,
  fetchurl,
  makeDesktopItem,
  writeShellApplication,
  ...
}:

let
  wine = if stdenv.hostPlatform.isDarwin then gcenx-wine-staging else wineWow64Packages.full;

  src = fetchurl {
    url = "https://downloads.guitar-pro.com/gp8/stable/guitar-pro-8-setup.exe";
    hash = "sha256-ZC60AHJe50k94Wldr90swSg2xy7WxOo3eZ+9dn6jXW4=";
  };

  pname = "guitar-pro";
  version = "8";

  myLib = import ../../../lib { inherit pkgs; };
  inherit (myLib) copyDesktopIcons mkWindowsAppNoCC;

  meta = with lib; {
    mainProgram = pname;
    homepage = "https://www.guitar-pro.com/";
    description = "Guitar Pro 8 tablature editor (packaged via Wine)";
    longDescription = lib.optionalString stdenv.hostPlatform.isDarwin ''
      On macOS this package uses gcenx-wine-staging (Gcenx WineHQ builds;
      https://github.com/Gcenx/macOS_Wine_builds) instead of nixpkgs Wine. The
      Windows installer runs into a user Wine prefix on first launch (override
      with GUITAR_PRO_WINEPREFIX).
    '';
    license = licenses.unfree;
    maintainers = [ ];
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
    ];
  };

  # Darwin cannot use mkWindowsApp (Linux overlayfs). Launch via Gcenx Wine.
  darwin = writeShellApplication {
    name = pname;
    runtimeInputs = [ wine ];
    inherit meta;
    text = ''
      set -euo pipefail
      export WINEARCH=win64
      export WINEPREFIX="''${GUITAR_PRO_WINEPREFIX:-''${XDG_DATA_HOME:-$HOME/.local/share}/guitar-pro/wineprefix}"
      marker="$WINEPREFIX/.guitar-pro-installed"
      installer="${src}"
      app="$WINEPREFIX/drive_c/Program Files/Arobas Music/Guitar Pro 8/GuitarPro.exe"

      if [ ! -e "$marker" ]; then
        mkdir -p "$WINEPREFIX"
        echo "Installing Guitar Pro into $WINEPREFIX..."
        wine boot --init
        wineserver -w
        wine start /unix "$installer" /S /VERYSILENT /SUPPRESSMSGBOXES
        wineserver -w
        touch "$marker"
      fi

      exec wine start /unix "$app" "$@"
    '';
  };

  linux = mkWindowsAppNoCC rec {
    inherit
      wine
      pname
      version
      src
      meta
      ;
    dontUnpack = true;
    wineArch = "win64";

    enableMonoBootPrompt = false;
    nativeBuildInputs = [
      copyDesktopItems
      copyDesktopIcons
    ];

    winAppInstall = ''
      $WINE start /unix ${src} /S /VERYSILENT /SUPPRESSMSGBOXES
      wineserver -w
    '';

    winAppRun = ''
      $WINE start /unix "$WINEPREFIX/drive_c/Program Files/Arobas Music/Guitar Pro 8/GuitarPro.exe" "$ARGS"
    '';

    installPhase = ''
      runHook preInstall
      mv $out/bin/.launcher $out/bin/${pname}
      runHook postInstall
    '';

    desktopItems = [
      (makeDesktopItem {
        name = "Guitar Pro";
        exec = pname;
        icon = pname;
        desktopName = "Guitar Pro";
        genericName = "Tablature Editor";
        categories = [
          "AudioVideo"
          "Audio"
        ];
      })
    ];
  };
in
if stdenv.hostPlatform.isDarwin then darwin else linux
