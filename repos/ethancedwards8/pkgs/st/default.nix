{ lib, stdenv, pkg-config, writeText, libX11, ncurses
, libXft, conf ? null, patches ? [], extraLibs ? [], fetchFromGitHub }:

with lib;

stdenv.mkDerivation rec {
  pname = "st";
  version = "0.8.4";

  src = fetchFromGitHub {
    owner = "ethancedwards";
    repo = "st-config";
    rev = "0eedc647ff2c4d19fdaa8c27d4ae0649e44b83e5";
    sha256 = "oojXFwuYJD9sfbntje9UQ//0bOBtGt0RyFeYwWV7eZo=";
  };

  inherit patches;

  configFile = optionalString (conf!=null) (writeText "config.def.h" conf);

  postPatch = optionalString (conf!=null) "cp ${configFile} config.def.h"
            + optionalString stdenv.isDarwin ''
    substituteInPlace config.mk --replace "-lrt" ""
  '';

  nativeBuildInputs = [ pkg-config ncurses ];
  buildInputs = [ libX11 libXft ] ++ extraLibs;

  installPhase = ''
    TERMINFO=$out/share/terminfo make install PREFIX=$out
  '';

  meta = {
    homepage = "https://st.suckless.org/";
    description = "Simple Terminal for X from Suckless.org Community";
    license = licenses.mit;
    maintainers = with maintainers; [ andsild ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
