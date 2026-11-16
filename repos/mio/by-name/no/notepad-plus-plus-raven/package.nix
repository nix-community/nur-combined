{
  lib,
  stdenv,
  pkgs,
  raven,
  fetchurl,
  copyDesktopItems,
  makeDesktopItem,
  unzip,
  writeShellScriptBin,
  testers,
}:

# Raven is tested against the official MSVC Notepad++ builds (installer/portable).
# Our MinGW PE currently fails under Raven (msvcrt.dll!__wargv), so this variant
# ships the upstream portable x64 zip and launches it with raven.
let
  pname = "notepad-plus-plus-raven";
  version = "8.9.9.1";

  notepadppPortable = stdenv.mkDerivation {
    pname = "notepadpp-portable";
    inherit version;

    src = fetchurl {
      url = "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v${version}/npp.${version}.portable.x64.zip";
      hash = "sha256-y876NGd+EP5t0ZgC99azuYYM1t5ir+qudoDgnFG0d3k=";
    };

    nativeBuildInputs = [ unzip ];

    dontConfigure = true;
    dontBuild = true;

    unpackPhase = ''
      runHook preUnpack
      unzip -q "$src" -d source
      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p "$out"
      cp -a source/. "$out/"
      # Prefer AppData inside the Raven prefix over portable local conf.
      rm -f "$out/doLocalConf.xml"
      runHook postInstall
    '';
  };

  launcher = writeShellScriptBin pname ''
    set -euo pipefail
    export RAVEN_PREFIX="''${RAVEN_PREFIX:-''${XDG_DATA_HOME:-$HOME/.local/share}/notepad-plus-plus-raven/prefix}"
    appdir="$RAVEN_PREFIX/drive_c/Program Files/Notepad++"
    marker="$RAVEN_PREFIX/.notepadpp-installed"
    app="$appdir/notepad++.exe"

    if [ ! -e "$marker" ]; then
      mkdir -p "$appdir"
      echo "Staging Notepad++ into $RAVEN_PREFIX..."
      cp -a ${notepadppPortable}/. "$appdir/"
      touch "$marker"
    fi

    desktop_flag=--desktop=x11
    if [ -n "''${WAYLAND_DISPLAY:-}" ]; then
      desktop_flag=--desktop=wayland
    elif [ -z "''${DISPLAY:-}" ]; then
      echo "notepad-plus-plus-raven: need WAYLAND_DISPLAY or DISPLAY" >&2
      exit 1
    fi

    exec ${lib.getExe raven} --run-process --execution=native --stdio=inherit \
      "$desktop_flag" "$app" -- "$@"
  '';
in
stdenv.mkDerivation (finalAttrs: {
  inherit pname version;

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [ copyDesktopItems ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp ${launcher}/bin/${pname} $out/bin/${pname}
    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "Notepad++-Raven";
      exec = pname;
      desktopName = "Notepad++ (Raven)";
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
      notepad-plus-plus-raven = finalAttrs.finalPackage;
      nixpkgsPath = pkgs.path;
    }
  );

  meta = with lib; {
    mainProgram = pname;
    homepage = "https://notepad-plus-plus.org/";
    description = "Notepad++ (official Windows build, run with Raven)";
    longDescription = ''
      Stages the official Notepad++ portable x64 build into a Raven prefix and
      launches it with raven --run-process. Raven currently targets the MSVC
      Windows builds (MinGW PEs need msvcrt exports Raven does not provide yet).
      Override the prefix with RAVEN_PREFIX.
    '';
    license = licenses.gpl3Plus;
    maintainers = [ "maydayv7" ];
    platforms = [ "x86_64-linux" ];
  };
})
