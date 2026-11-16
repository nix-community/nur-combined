{
  lib,
  stdenv,
  pkgs,
  pkgsCross,
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

  myLib = import ../../../lib { inherit pkgs; };
  inherit (myLib) copyDesktopIcons makeDesktopIcon mkWindowsAppNoCC;

  # Build-time Wine for the upstream .bat (same selection as runtime).
  notepadppWindows = pkgs.callPackage ./windows.nix {
    inherit pkgsCross wine;
  };

  pname = "notepad-plus-plus";
  version = notepadppWindows.version;

  meta = with lib; {
    mainProgram = pname;
    homepage = "https://notepad-plus-plus.org/";
    description = "Notepad++ (MinGW source build, run with Wine)";
    longDescription = ''
      Cross-compiles Notepad++ from source with MinGW-w64 on the builder, then
      launches the Windows PE under Wine. On macOS this uses gcenx-wine-staging
      instead of nixpkgs Wine.
    '';
    license = licenses.gpl3Plus;
    maintainers = [ "maydayv7" ];
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
  };

  desktopIcon = makeDesktopIcon {
    name = pname;
    icoIndex = 2;
    src = fetchurl {
      url = "https://notepad-plus-plus.org/favicon.ico";
      sha256 = "1av2m6m665ccfngnzqnbsnv2aky907p2c6ggvfxrwbp70szgj9vi";
    };
  };

  linux = mkWindowsAppNoCC rec {
    inherit
      wine
      pname
      version
      meta
      desktopIcon
      ;
    src = notepadppWindows;

    dontUnpack = true;
    wineArch = "win64";

    fileMap = {
      "$HOME/.config/Notepad++" = "drive_c/users/$USER/AppData/Roaming/Notepad++";
    };

    enableMonoBootPrompt = false;
    nativeBuildInputs = [
      copyDesktopItems
      copyDesktopIcons
    ];

    winAppInstall = ''
      mkdir -p "$WINEPREFIX/drive_c/Program Files/Notepad++"
      cp -r ${src}/* "$WINEPREFIX/drive_c/Program Files/Notepad++/"
      winetricks --unattended cjkfonts
    '';

    winAppRun = ''
      $WINE start /unix "$WINEPREFIX/drive_c/Program Files/Notepad++/notepad++.exe" "$ARGS"
    '';

    installPhase = ''
      runHook preInstall
      mv $out/bin/.launcher $out/bin/${pname}
      runHook postInstall
    '';

    desktopItems = [
      (makeDesktopItem {
        name = "Notepad++";
        exec = pname;
        icon = pname;
        desktopName = "Notepad++";
        genericName = "Text Editor";
        mimeTypes = [ "text/plain" ];
        categories = [
          "Utility"
          "TextEditor"
        ];
      })
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
      export WINEPREFIX="''${NOTEPADPP_WINEPREFIX:-''${XDG_DATA_HOME:-$HOME/.local/share}/notepad-plus-plus/wineprefix}"
      marker="$WINEPREFIX/.notepadpp-installed"
      appdir="$WINEPREFIX/drive_c/Program Files/Notepad++"
      app="$appdir/notepad++.exe"

      if [ ! -e "$marker" ]; then
        mkdir -p "$appdir"
        echo "Installing Notepad++ into $WINEPREFIX..."
        wine boot --init
        wineserver -w
        cp -a ${notepadppWindows}/. "$appdir/"
        touch "$marker"
      fi

      exec wine start /unix "$app" "$@"
    '';
  };
in
if stdenv.hostPlatform.isDarwin then darwin else linux
