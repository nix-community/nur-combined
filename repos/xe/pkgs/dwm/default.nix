{stdenv, fetchgit, libX11, libXinerama, libXft}:

let
  pname = "dwm";
  version = "6.2-kadis";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchgit {
    url = "https://tulpa.dev/cadey/dwm.git";
    rev = "2a30ea769c87396284829fa5201d445f4779da27";
    sha256 = "1czlm6k0vb6sngkqwgs9pdr40k3xi9w2zd7c5736pw35f5q97dfc";
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
