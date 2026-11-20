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
  testers,
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

  # Where the payload lives inside every Wine prefix. Both launchers use it.
  winAppDir = "drive_c/Program Files/Notepad++";
  winAppExe = "$WINEPREFIX/${winAppDir}/notepad++.exe";

  # Installs the cross-compiled payload into $WINEPREFIX. Linux runs this when
  # building its prefix; darwin runs it on first launch. cjkfonts is only
  # available through winetricks on Linux, so darwin opts out.
  installPayload =
    { cjkfonts }:
    ''
      mkdir -p "$WINEPREFIX/${winAppDir}"
      cp -a ${notepadppWindows}/. "$WINEPREFIX/${winAppDir}/"
      chmod -R u+rwX "$WINEPREFIX/${winAppDir}"
    ''
    + lib.optionalString cjkfonts ''
      if [ "''${NOTEPADPP_SKIP_CJKFONTS:-}" != 1 ]; then
        winetricks --unattended cjkfonts
      fi
    '';

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

    winAppInstall = installPayload { cjkfonts = true; };

    winAppRun = ''
      $WINE "${winAppExe}" "''${ARGS[@]}"
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

    passthru.tests.nixos = testers.runNixOSTest (
      import ./test.nix {
        notepad-plus-plus = linux;
        nixpkgsPath = pkgs.path;
      }
    );
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
      app="${winAppExe}"

      if [ ! -e "$marker" ]; then
        echo "Installing Notepad++ into $WINEPREFIX..."
        # wineboot exits non-zero on macOS/Gcenx (wine-mono's MSI and the missing
        # Microsoft.Windows.Common-Controls manifest) even though the prefix is
        # usable. With `set -e` that aborted the install before the payload was
        # copied, so the prefix kept an empty app dir and no marker, and
        # `wine start` then failed with "ShellExecuteEx failed: File not found".
        wine boot --init || true
        wineserver -w || true
        # wineboot may have (re)created drive_c after the mkdir above.
        ${installPayload { cjkfonts = false; }}
        [ -f "$app" ] || {
          echo "error: notepad++.exe missing from ${winAppDir}" >&2
          exit 1
        }
        touch "$marker"
      fi

      exec wine start /unix "$app" "$@"
    '';
  };
in
if stdenv.hostPlatform.isDarwin then darwin else linux
