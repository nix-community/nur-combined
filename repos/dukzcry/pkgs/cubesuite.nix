{ wrapWine, makeDesktopItem, fetchFromGitHub, unzip, ... }:
let
  src = fetchFromGitHub {
    owner = "repos-holder";
    repo = "binaries";
    rev = "a52e76e19e596cb9fbe226515fc8130a7fed3ba4";
    sha256 = "sha256-WivF8GC9Lx/Y57eObyvi9PYhEmaf7A/0Wn6LbPqK1bI=";
  };
  bin = wrapWine {
    name = "cubesuite";
    executable = "$WINEPREFIX/drive_c/CubeSuite/CubeSuite.exe";
    firstrunScript = ''
      pushd "$WINEPREFIX/drive_c"
        ${unzip}/bin/unzip ${src}/CubeSuite+V2.7.8+for+Windows+OS.zip
      popd
    '';
  };
in makeDesktopItem {
  name = "cubesuite";
  desktopName = "CubeSuite";
  type = "Application";
  exec = ''${bin}/bin/cubesuite'';
}
