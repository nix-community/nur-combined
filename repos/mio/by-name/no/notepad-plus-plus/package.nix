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
  isDarwin = stdenv.hostPlatform.isDarwin;

  wine = if isDarwin then gcenx-wine-staging else wineWow64Packages.full;

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

  # Everything both platform builds must agree on. Linux hands this straight to
  # mkWindowsAppNoCC; darwin uses the same values in the loose launcher below.
  common = {
    inherit
      wine
      pname
      version
      meta
      ;
    src = notepadppWindows;
    dontUnpack = true;
    wineArch = "win64";
    enableMonoBootPrompt = false;
  };

  # Installs the cross-compiled payload into $WINEPREFIX. Linux runs this while
  # building its app layer, darwin on first launch. cjkfonts is only available
  # through winetricks on Linux, so darwin opts out.
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

  # Starts the PE. mkWindowsApp's launcher fills ARGS from its argv; the darwin
  # launcher sets ARGS=( "$@" ) before calling this, so both run this one
  # command instead of keeping a launch line per platform.
  winAppRun = ''$WINE "${winAppExe}" "''${ARGS[@]}"'';

  desktopIcon = makeDesktopIcon {
    name = pname;
    icoIndex = 2;
    src = fetchurl {
      url = "https://notepad-plus-plus.org/favicon.ico";
      hash = "sha256-cSf5vgbnLp672+8ZJu4ByU8lttXL4m+fdYwVY6qpYqs=";
    };
  };

  linux = mkWindowsAppNoCC (
    common
    // rec {
      inherit desktopIcon winAppRun;

      fileMap = {
        "$HOME/.config/Notepad++" = "drive_c/users/$USER/AppData/Roaming/Notepad++";
      };

      nativeBuildInputs = [
        copyDesktopItems
        copyDesktopIcons
      ];

      # Linux bootstraps the prefix when building its app layer, so it can also
      # install the CJK fonts there.
      winAppInstall = installPayload { cjkfonts = true; };

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
    }
  );

  # Darwin cannot use mkWindowsApp (Linux overlayfs), so this is a plain
  # launcher: it bootstraps the prefix on first launch with the same payload
  # install and then starts the PE with the same winAppRun command.
  darwin = writeShellApplication {
    name = pname;
    runtimeInputs = [ wine ];
    meta = common.meta;
    text = ''
      set -euo pipefail
      export WINEARCH=${common.wineArch}
      export WINEPREFIX="''${NOTEPADPP_WINEPREFIX:-''${XDG_DATA_HOME:-$HOME/.local/share}/${pname}/wineprefix}"
      ARGS=( "$@" )
      # Same selection mkWindowsApp's launcher makes, done at runtime to avoid
      # IFD on the wine output.
      WINE="${wine}/bin/wine64"
      if [ ! -e "$WINE" ]; then
        WINE="${wine}/bin/wine"
      fi
      marker="$WINEPREFIX/.notepadpp-installed"
      app="${winAppExe}"

      if [ ! -e "$marker" ]; then
        echo "Installing ${pname} into $WINEPREFIX..."
        # wineboot exits non-zero on macOS/Gcenx (wine-mono's MSI and the missing
        # Microsoft.Windows.Common-Controls manifest) even though the prefix is
        # usable. With `set -e` that aborted the install before the payload was
        # copied, so the prefix kept an empty app dir and no marker, and the
        # launcher then failed with "ShellExecuteEx failed: File not found".
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

      # exec, unlike mkWindowsApp's launcher which must keep the shell alive for
      # its cleanup hooks, so signals reach the app instead of this wrapper.
      exec ${winAppRun}
    '';
  };
in
if isDarwin then darwin else linux
