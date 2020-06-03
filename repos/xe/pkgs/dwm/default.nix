{stdenv, fetchgit, libX11, libXinerama, libXft}:

let
  pname = "dwm";
  version = "6.2-kadis";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchgit {
    url = "https://tulpa.dev/cadey/dwm.git";
    rev = "8ea55d397459a865041b96d5b4933f426d010e6d";
    sha256 = "1agvjzan1wxic2qzmkmr74clpbfpp9izr6cldp0l7ah6ivscz0z4";
  };

  buildInputs = [ libX11 libXinerama libXft ];

  prePatch = ''sed -i "s@/usr/local@$out@" config.mk'';

  buildPhase = " make ";

  meta = {
    homepage = "https://suckless.org/";
    description = "Dynamic window manager for X";
    license = stdenv.lib.licenses.mit;
    maintainers = with stdenv.lib.maintainers; [xe];
    platforms = with stdenv.lib.platforms; all;
  };
}
