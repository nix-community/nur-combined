{stdenv, fetchgit, libX11, libXinerama, libXft}:

let
  pname = "dwm";
  version = "6.2-kadis";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchgit {
    url = "https://tulpa.dev/cadey/dwm.git";
    rev = "299c70874c5eb062ccbe9781cabccecb60452489";
    sha256 = "195gcpc7s2m64i2v3ld5bb3xm4yh777s8m79h4hhi4q73c7wvjs6";
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
