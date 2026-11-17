{
  lib,
  stdenvNoCC,
  wine4office,
  curl,
  coreutils,
  writeShellApplication,
}:

let
  inherit (wine4office) version;

  wordExe = "drive_c/Program Files/Microsoft Office/root/Office16/WINWORD.EXE";

  installWord = writeShellApplication {
    name = "wine4office-install-word";
    runtimeInputs = [
      curl
      coreutils
    ];
    text = ''
      set -euo pipefail

      wine="${wine4office}/bin/wine"
      wineserver="${wine4office}/bin/wineserver"
      configuration="${./word-configuration.xml}"
      setup=""

      usage() {
        echo "Usage: wine4office-install-word [--configuration FILE] [--setup FILE] [--prefix DIR]"
        echo
        echo "Silently installs 64-bit Microsoft Word into a Wine4Office prefix"
        echo "using Microsoft's Office Deployment Tool (ODT)."
        echo
        echo "  --configuration FILE  ODT configuration XML (default: Word only, Microsoft 365 Apps, Current channel)"
        echo "  --setup FILE          reuse an existing ODT setup.exe instead of downloading it"
        echo "  --prefix DIR          Wine prefix (default: \$WINEPREFIX or ~/.wine4office)"
        echo
        echo "The ODT setup.exe is cached in \$XDG_CACHE_HOME/wine4office/odt and can"
        echo "also be supplied through WINE4OFFICE_ODT_SETUP."
      }

      while [ "$#" -gt 0 ]; do
        case "$1" in
          --configuration)
            configuration="$2"
            shift 2
            ;;
          --setup)
            setup="$2"
            shift 2
            ;;
          --prefix)
            WINEPREFIX="$2"
            export WINEPREFIX
            shift 2
            ;;
          -h | --help)
            usage
            exit 0
            ;;
          *)
            echo "unknown argument: $1" >&2
            usage >&2
            exit 2
            ;;
        esac
      done

      export WINEPREFIX="''${WINEPREFIX:-$HOME/.wine4office}"
      cache="''${XDG_CACHE_HOME:-$HOME/.cache}/wine4office/odt"

      if [ -z "$setup" ]; then
        setup="''${WINE4OFFICE_ODT_SETUP:-$cache/setup.exe}"
        if [ ! -s "$setup" ]; then
          mkdir -p "$cache"
          echo "Downloading the Office Deployment Tool bootstrapper..."
          curl --fail --location --retry 3 --output "$setup.part" \
            https://officecdn.microsoft.com/pr/wsus/setup.exe
          mv "$setup.part" "$setup"
        fi
      fi
      if [ ! -s "$setup" ]; then
        echo "ODT setup.exe not found: $setup" >&2
        exit 1
      fi

      echo "Initializing the Wine prefix at $WINEPREFIX..."
      "$wine" wineboot --init
      "$wineserver" -w

      configuration_win=$("$wine" winepath -w "$configuration" | tr -d '\r\n')
      echo "Installing Word into $WINEPREFIX (silent; Office is downloaded from Microsoft)..."
      "$wine" "$setup" /configure "$configuration_win"
      "$wineserver" -w

      word="$WINEPREFIX/${wordExe}"
      if [ -f "$word" ]; then
        echo "Word is installed: $word"
        echo "Launch it with: wine4office-word"
      else
        echo "ODT finished but WINWORD.EXE was not found under $WINEPREFIX." >&2
        echo "Check the Office installation logs in $WINEPREFIX/drive_c/users/$USER/Temp." >&2
        exit 1
      fi
    '';
  };

  word = writeShellApplication {
    name = "wine4office-word";
    text = ''
      set -euo pipefail

      export WINEPREFIX="''${WINEPREFIX:-$HOME/.wine4office}"
      word="$WINEPREFIX/${wordExe}"

      if [ ! -f "$word" ]; then
        echo "Word is not installed in $WINEPREFIX." >&2
        echo "Run wine4office-install-word first." >&2
        exit 1
      fi

      exec "${wine4office}/bin/wine" "$word" "$@"
    '';
  };
in
stdenvNoCC.mkDerivation {
  pname = "wine4office-word";
  inherit version;

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 ${installWord}/bin/wine4office-install-word $out/bin/wine4office-install-word
    install -Dm755 ${word}/bin/wine4office-word $out/bin/wine4office-word
    install -Dm644 ${./word-configuration.xml} $out/share/wine4office/word-configuration.xml

    runHook postInstall
  '';

  meta = {
    description = "Install and launch Microsoft Word in a Wine4Office prefix using the Office Deployment Tool";
    homepage = "https://github.com/ttv20/wine4office";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "wine4office-install-word";
  };
}
