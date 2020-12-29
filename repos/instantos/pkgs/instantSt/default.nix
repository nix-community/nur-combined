{ stdenv, fetchFromGitHub, pkgconfig, writeText, libX11, ncurses
, libXft, harfbuzz, firacodenerd, conf ? null, patches ? [], extraLibs ? []}:

with stdenv.lib;

stdenv.mkDerivation rec {
  pname = "instantSt";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "instantOS";
    repo = "st-instantos";
    rev = "bfe35d5ebe539998d300ce3fb2fd083a5030ad5d";
    sha256 = "sha256-8Mf1DmdNXFjoyuQzLjn9UI/K613DjFyHshihsEe9lSI=";
    name = "instantOS_instantST";
  };

  inherit patches;

  configFile = optionalString (conf!=null) (writeText "config.def.h" conf);
  postPatch = optionalString (conf!=null) "cp ${configFile} config.def.h";

  nativeBuildInputs = [ pkgconfig ncurses ];
  buildInputs = [ libX11 libXft harfbuzz firacodenerd ] ++ extraLibs;

  installPhase = ''
    TERMINFO=$out/share/terminfo make install PREFIX=$out
  '';

  meta = {
    homepage = "https://github.com/instantOS/st-instantos";
    description = "InstatOS terminal derived from suckless' st";
    license = licenses.mit;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com" ]; 
    platforms = platforms.linux;
  };
}
