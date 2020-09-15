{ stdenv, fetchFromGitHub, pkgconfig, writeText, libX11, ncurses
, libXft, harfbuzz, firacodenerd, conf ? null, patches ? [], extraLibs ? []}:

with stdenv.lib;

stdenv.mkDerivation rec {
  pname = "instantSt";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "instantOS";
    repo = "st-instantos";
    rev = "e8f64648285bf79e6d8cce180d3108cc135dd101";
    sha256 = "0360g640rnrp8ylx316v8w4dnbpaj5ywa404dngvv8f9c6wmi455";
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
