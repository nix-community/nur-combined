{pkgs}:
let
  source = builtins.fetchurl {
    url = "https://www.7-zip.org/a/7z1900.exe";
    sha256 = "107gnx5rimmyr0kndxblkhrwlqn9x1aga7d07ghyxsq3bd6s16km";
  };
in pkgs.wrapWine {
  name = "7zip";
  firstrunScript = ''
    wine ${source}
  '';
  executable = "$WINEPREFIX/drive_c/Program Files/7-Zip/7zFM.exe";
}
