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
      url = "https://downloads.cursor.com/production/60d42bed27e5775c43ec0428d8c653c49e58e26a/linux/x64/Cursor-2.1.39-x86_64.AppImage";
      hash = "sha256-SsKhW8q/AzOn1HqykhwaVHyTVm+OqTUiFtda7XDiAho=";
    };
    x86_64-darwin = fetchurl {
      url = "https://downloads.cursor.com/production/60d42bed27e5775c43ec0428d8c653c49e58e26a/darwin/x64/Cursor-darwin-x64.dmg";
      hash = "sha256-kFjKAoRMxRJqBC75LCcbEiwqdunaphj/e2afrFD3NaM=";
    };
    aarch64-darwin = fetchurl {
      url = "https://downloads.cursor.com/production/60d42bed27e5775c43ec0428d8c653c49e58e26a/darwin/arm64/Cursor-darwin-arm64.dmg";
      hash = "sha256-9kP0C7KLLSD0Oak75P/4Qt5sIncTwW6Sldz2/9yi4EE=";
    };
  };

  source = sources.${hostPlatform.system};
in
(pkgs.callPackage (pkgs.path + "/pkgs/applications/editors/vscode/generic.nix") rec {
  inherit useVSCodeRipgrep;
  commandLineArgs = finalCommandLineArgs;

  version = "2.1.39";
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
        inherit pname version;
        src = source;
      }
    else
      source;

  sourceRoot =
    if hostPlatform.isLinux then "${pname}-${version}-extracted/usr/share/cursor" else "Cursor.app";

  tests = { };

  updateScript = ./update.sh;

  # Editing the `cursor` binary within the app bundle causes the bundle's signature
  # to be invalidated, which prevents launching starting with macOS Ventura, because Cursor is notarized.
  # See https://eclecticlight.co/2022/06/17/app-security-changes-coming-in-ventura/ for more information.
  dontFixup = stdenv.hostPlatform.isDarwin;

  # Cursor has no wrapper script.
  patchVSCodePath = false;

  meta = {
    description = "AI-powered code editor built on vscode";
    homepage = "https://cursor.com";
    changelog = "https://cursor.com/changelog";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = "lmdevv";
    platforms = [
      "x86_64-linux"
    ]
    ++ lib.platforms.darwin;
    mainProgram = "cursor";
  };
}).overrideAttrs
  (oldAttrs: {
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
