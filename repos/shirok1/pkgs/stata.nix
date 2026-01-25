{
  lib,
  stdenv,
  pkgs,
  autoPatchelfHook,
  libgcc,
  curl,
  zlib,
  ncurses,
  ...
}:
let
  pname = "stata";
  majorVersion = "19.5";
  buildDate = "2025-05-07";

  isstataSuffix = builtins.replaceStrings [ "." ] [ "" ] majorVersion;
in
stdenv.mkDerivation {
  inherit pname;
  version = "${majorVersion}+${buildDate}";

  src = pkgs.requireFile {
    name = "StataNow19Linux64.tar.gz";
    url = "https://www.stata.com/";
    sha256 = "sha256-X1aRoxJSgVLJEDAuBff7BbLY+DEHgOQ1sQXNAe3XY6M=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];
  buildInputs = [
    libgcc.lib
    zlib
    curl

    ncurses # for TUI

    # gtk2
    # glib
    # pango
    # atk
    # cairo
    # gdk-pixbuf
    # fontconfig
    # freetype

    # xorg.libX11
    # xorg.libXext
    # xorg.libXrender
  ];

  installPhase = ''
    mkdir -p $out
    cd ..

    tar xzf unix/linux64/base.taz --directory=$out
    tar xzf unix/linux64/bins.taz --directory=$out --exclude=utilities/java --exclude=xstata --exclude=xstata-se --exclude=xstata-mp
    tar xzf unix/linux64/ado.taz --directory=$out
    tar xzf unix/linux64/docs.taz --directory=$out

    if [ ! -f "$out/isstata.${isstataSuffix}" ]; then
      echo "ERROR: expected marker file isstata.${isstataSuffix} not found"
      echo "  (derived from majorVersion=${majorVersion})"
      echo "  available isstata.* files:"
      ls -1 isstata.* 2>/dev/null || true
      exit 1
    fi

    if [ ! -f $out/utilities/update ]; then
      echo "ERROR: utilities/update not found"
      exit 1
    fi

    expected="$(date -u -d "${buildDate}" '+%d %b %Y')"
    actual="$(sed -n '1p' $out/utilities/update)"

    if [ "$actual" != "$expected" ]; then
      echo "ERROR: Stata build date mismatch"
      echo "  expected: $expected"
      echo "  actual:   $actual"
      exit 1
    fi

    ln -s /etc/stata.lic $out/stata.lic
  '';

  meta = with lib; {
    description = "Stata is a general-purpose statistical software package developed by StataCorp for data manipulation, visualization, statistics, and automated reporting.";
    homepage = "https://www.stata.com/";
    license = licenses.unfree;
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = pname;
  };
}
