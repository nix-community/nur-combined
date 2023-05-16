{ pkgs, fetchzip, fetchurl, stdenv, wineStable, makeDesktopItem, writeShellScriptBin, ... }:
let
  paint = fetchzip {
    url = "https://archive.org/download/MSPaintWinXP/mspaint%20WinXP%20English.zip";
    sha256 = "119c7304szbky9n0d7761qvl09fmg9wh4ilna7fzcj691igly562";
  };
  dll = fetchurl {
    url = "https://www.dlldump.com/dllfiles/M/mfc42u.dll";
    sha256 = "12mi28j78p8350pn38iqkmcxxz69xmbz7k9ws76i7xv825siv8gi";
  };
  theDerivation = stdenv.mkDerivation {
    name = "mspaint-xp-base";
    version = "1.0";

    src = paint;

    installPhase = ''
      mkdir -p "$out"
      cp -r "$src/mspaint.exe" "$out/mspaint.exe"
      cp "${dll}" "$out/mfc42u.dll"
    '';
    enablePatchelf = false;
  };
  bin = writeShellScriptBin "mspaint" ''
    ${wineStable}/bin/wine ${theDerivation}/mspaint.exe
  '';
in
makeDesktopItem {
  name = "paint";
  desktopName = "Paint WindowsXP";
  icon = fetchurl {
    url = "http://vignette3.wikia.nocookie.net/logopedia/images/4/45/Ms_paint_windows_xp_logo.png/revision/latest?cb=20160414044336";
    sha256 = "sha256:1sznr3mdx6bk2ijs0n4q31chb1p64i54bmynm8njsxq4l11lnqph";
  };
  type = "Application";
  exec = "${bin}/bin/mspaint $*";
}
