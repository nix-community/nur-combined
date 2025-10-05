{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages,
  curses-menu,
}:

python3Packages.buildPythonApplication {
  pname = "miband4";
  version = "0-unstable-2022-10-07";
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
      pythonEnv = python3Packages.python.withPackages (
        p: with p; [
          bluepy
          pycrypto
          curses-menu
        ]
      );
    in
    ''
      site_packages=$out/lib/${python3Packages.python.libPrefix}/site-packages
      mkdir -p $site_packages
      cp *.py $site_packages

      makeWrapper ${pythonEnv.interpreter} $out/bin/miband4_console \
        --add-flags "$site_packages/miband4_console.py"
    '';

  meta = {
    description = "Access Xiaomi MiBand 4 from Linux using Bluetooth LE";
    homepage = "https://github.com/satcar77/miband4";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
}
