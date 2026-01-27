{
  lib,
  stdenv,
  fetchurl,
  appimageTools,
  undmg,
  commandLineArgs ? "",
  useVSCodeRipgrep ? stdenv.hostPlatform.isDarwin,
  pkgs,
  steam-run,
}:

let
  inherit (stdenv) hostPlatform;
  finalCommandLineArgs = "--update=false " + commandLineArgs;

  sources = {
    x86_64-linux = fetchurl {
      url = "https://downloads.cursor.com/production/dc8361355d709f306d5159635a677a571b277bcc/linux/x64/Cursor-2.4.21-x86_64.AppImage";
      hash = "sha256-OOjANfVHMlRN1uWq2jNmK/RqI4Q5NTlN/19Nl2jWiKI=";
    };
    x86_64-darwin = fetchurl {
      url = "https://downloads.cursor.com/production/dc8361355d709f306d5159635a677a571b277bcc/darwin/x64/Cursor-darwin-x64.dmg";
      hash = "sha256-uacRpz0HFRfmaNekSB5qLXpnhiQRvAw03W+9QfPl6ZY=";
    };
    aarch64-darwin = fetchurl {
      url = "https://downloads.cursor.com/production/dc8361355d709f306d5159635a677a571b277bcc/darwin/arm64/Cursor-darwin-arm64.dmg";
      hash = "sha256-nCch/JXO1lzj0ibAa8e0OPlnBTOrIk/fvq9CO46Ev8w=";
    };
  };

  source = sources.${hostPlatform.system};

  metaAttrs = {
    description = "AI-powered code editor built on vscode";
    homepage = "https://cursor.com";
    changelog = "https://cursor.com/changelog";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ ];
    platforms = [
      "x86_64-linux"
    ] ++ lib.platforms.darwin;
    mainProgram = "cursor";
  };

  genericNix = import (pkgs.path + "/pkgs/applications/editors/vscode/generic.nix");
  genericArgs = builtins.functionArgs genericNix;
  # Check if the generic.nix accepts 'meta' as an argument (older nixpkgs) or not (newer nixpkgs)
  acceptsMeta = genericArgs ? meta;

  baseArgs = {
    inherit useVSCodeRipgrep;
    commandLineArgs = finalCommandLineArgs;

    version = "2.4.21";
    pname = "cursor";

    # You can find the current VSCode version in the About dialog:
    # workbench.action.showAboutDialog (Help: About)
    vscodeVersion = "1.99.3";

    executableName = "cursor";
    longName = "Cursor";
    shortName = "cursor";
    libraryName = "cursor";
    iconName = "cursor";

    src =
      if hostPlatform.isLinux then
        appimageTools.extract {
          pname = "cursor";
          version = "2.4.21";
          src = source;
        }
      else
        source;

    sourceRoot =
      if hostPlatform.isLinux then "cursor-2.4.21-extracted/usr/share/cursor" else "Cursor.app";

    tests = { };

    updateScript = ./update.sh;

    # Editing the `cursor` binary within the app bundle causes the bundle's signature
    # to be invalidated, which prevents launching starting with macOS Ventura, because Cursor is notarized.
    # See https://eclecticlight.co/2022/06/17/app-security-changes-coming-in-ventura/ for more information.
    dontFixup = stdenv.hostPlatform.isDarwin;

    # Cursor has no wrapper script.
    patchVSCodePath = false;
  };

  # Conditionally add meta if the function accepts it
  callArgs = baseArgs // lib.optionalAttrs acceptsMeta { meta = metaAttrs; };
in
(pkgs.callPackage (pkgs.path + "/pkgs/applications/editors/vscode/generic.nix") callArgs).overrideAttrs
  (oldAttrs: {
    # Always set meta in overrideAttrs to ensure it's present (for newer nixpkgs that don't accept meta arg)
    meta = metaAttrs;

    nativeBuildInputs =
      (oldAttrs.nativeBuildInputs or [ ]) ++ lib.optionals hostPlatform.isDarwin [ undmg ];

    # Wrap the cursor binary with steam-run for FHS compatibility on Linux
    postFixup = lib.optionalString hostPlatform.isLinux ''
      # Create a wrapper script that uses steam-run for FHS compatibility
      makeWrapper ${steam-run}/bin/steam-run $out/bin/cursor-wrapped \
        --add-flags "$out/bin/cursor-original" \
        --add-flags "$finalCommandLineArgs"
      
      # Replace the original cursor binary with our wrapper
      mv $out/bin/cursor $out/bin/cursor-original
      mv $out/bin/cursor-wrapped $out/bin/cursor
    '';

    buildInputs = (oldAttrs.buildInputs or [ ]) ++ lib.optionals hostPlatform.isLinux [ steam-run ];

    passthru = (oldAttrs.passthru or { }) // {
      inherit sources;
    };
  })
