# DOES NOT WORK
{ stdenv, lib, pkgs, qtbase, wrapQtAppsHook, qmake, qtmultimedia }: 

stdenv.mkDerivation {
  pname = "corgi3ds";
  version = "2020-07-15";

  src = pkgs.fetchFromGitHub {
    owner = "PSI-Rockin";
    repo = "Corgi3DS";
    rev = "master";
    sha256 = "sha256-CwF/4Am5+rw3XELjZTx9LtebAdoeMALhX42vopIgzU4=";
  };

  patches = [ ./include-cstdint.patch ./include-cstdio.patch ];

  buildInputs = [
    qtbase
    qtmultimedia
    pkgs.gmp
  ];

  nativeBuildInputs = [ qmake wrapQtAppsHook ]; 

  installPhase = ''
    mkdir -p $out/bin
    cp Corgi3DS $out/bin
  '';

  meta = with lib; {
    description = "An LLE dog-themed 3DS emulator";
    homepage = "https://github.com/PSI-Rockin/Corgi3DS";
    license = licenses.gpl3;
    platforms = platforms.unix;
    mainProgram = "Corgi3DS";
  };
}
