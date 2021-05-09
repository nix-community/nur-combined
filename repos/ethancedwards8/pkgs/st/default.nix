{ lib, stdenv, pkg-config, writeText, libX11, ncurses
, libXft, conf ? null, patches ? [], extraLibs ? [], fetchFromGitLab, ... }@inputs:

with lib;

stdenv.mkDerivation rec {
  __contentAddressed = true;
  pname = "st";
  version = "0.8.4";

  # src = inputs.st;
  src = fetchFromGitLab {
    owner = "ethancedwards";
    repo = "st-config";
    rev = "8dfefc7d84c4aa1785cd583fd027b90fd9df9771";
    sha256 = "aAkLLrZkwKsQWRTxJRbjrdLbeq01eMrvQhldF5kQBTk=";
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
