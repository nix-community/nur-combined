{ stdenv, fetchFromGitHub, cmake, pkgconfig
, enableGUI ? false, libGLU_combined ? null, fltk ? null
}:

assert enableGUI -> libGLU_combined != null && fltk != null;

with stdenv.lib;

stdenv.mkDerivation rec {

  pname = "freediag";
  version = "unstable-2020-18-06";

  src = fetchFromGitHub {
    owner = "fenugrec";
    repo = "freediag";
    rev = "f7885e4b7eaaee85bc718369e8b5c8e52fe2f8b8";
    sha256 = "0krwbz9jnyzjwmjkx1ffh7v3qk8r2xd4lg3jm9mqxyiw780r4n4s";
  };

  nativeBuildInputs = [ cmake pkgconfig ];
  buildInputs = optionals enableGUI [ libGLU_combined fltk ];

  cmakeFlags = optional enableGUI [ "-DBUILD_GUI=1" ] ;

  meta = {
    description = "Free diagnostic software for OBD-II compliant motor vehicles";
    homepage = https://freediag.sourceforge.net/;
    maintainers = [ maintainers.genesis ];
    platforms = platforms.linux;
    license = stdenv.lib.licenses.gpl3;
  };
}
