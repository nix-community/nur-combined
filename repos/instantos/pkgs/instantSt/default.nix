{ stdenv, lib, fetchFromGitHub, pkg-config, writeText, libX11, ncurses
, libXft, harfbuzz, firacodenerd, conf ? null, patches ? [], extraLibs ? []}:

with lib;

stdenv.mkDerivation rec {
  pname = "instantSt";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "instantOS";
    repo = "st-instantos";
    rev = "be01eccb5af9067b73fbce8787932aecfb6d4de9";
    sha256 = "XACYg2KjAbs4cw8rvCxVm8YOck/2dZhpHYeEEva513s=";
    name = "instantOS_instantST";
  };

  inherit patches;

  configFile = optionalString (conf!=null) (writeText "config.def.h" conf);
  postPatch = optionalString (conf!=null) "cp ${configFile} config.def.h";

  nativeBuildInputs = [ pkg-config ncurses ];
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
