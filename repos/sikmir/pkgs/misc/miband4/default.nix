{ lib, stdenv, fetchFromGitHub, python3Packages, curses-menu }:

python3Packages.buildPythonApplication rec {
  pname = "miband4";
  version = "2021-03-31";

  src = fetchFromGitHub {
    owner = "satcar77";
    repo = "miband4";
    rev = "4fdf6e9b4f4c5fd5c90b4ce2fbe5965d6bb82ea7";
    hash = "sha256-vLY9NhlZPCqqLvv6yW6L2gt0zwGGrxDmQK9+Z3PLVqI=";
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
    license = licenses.free;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
}
