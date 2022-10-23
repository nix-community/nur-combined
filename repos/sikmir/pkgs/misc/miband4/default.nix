{ lib, stdenv, fetchFromGitHub, python3Packages, curses-menu }:

python3Packages.buildPythonApplication rec {
  pname = "miband4";
  version = "2022-10-07";
  format = "other";

  src = fetchFromGitHub {
    owner = "satcar77";
    repo = "miband4";
    rev = "166f15bd6a3534fc1054501025a79d8d4db83f12";
    hash = "sha256-18ymMXMZLvC3JDCVgvSOQYHg7U3s76HHdVmiQEoBJzo=";
  };

  dontUseSetuptoolsBuild = true;
  dontUseSetuptoolsCheck = true;

  installPhase =
    let
      pythonEnv = python3Packages.python.withPackages (p: with p; [
        bluepy
        pycrypto
        curses-menu
      ]);
    in
    ''
      site_packages=$out/lib/${python3Packages.python.libPrefix}/site-packages
      mkdir -p $site_packages
      cp *.py $site_packages

      makeWrapper ${pythonEnv.interpreter} $out/bin/miband4_console \
        --add-flags "$site_packages/miband4_console.py"
    '';

  meta = with lib; {
    description = "Access Xiaomi MiBand 4 from Linux using Bluetooth LE";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
}
