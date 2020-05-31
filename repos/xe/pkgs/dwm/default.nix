{stdenv, fetchgit, libX11, libXinerama, libXft}:

let
  pname = "dwm";
  version = "6.2-kadis";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchgit {
    url = "https://tulpa.dev/cadey/dwm.git";
    rev = "14ad3d842ec1b373e572d5fb03764fd262a47846";
    sha256 = "18qq7q13zcn12dxvbd5w9v6v3lrgf05yhafpx6q9zvic4im32ppy";
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
