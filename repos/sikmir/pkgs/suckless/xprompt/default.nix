{ lib, stdenv, fetchFromGitHub, libX11, libXft, libXinerama }:

stdenv.mkDerivation rec {
  pname = "xprompt";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "phillbush";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-/Hyi0ZvOxS2MWzeX4Ng0QqOGzPGQytkBHwQufT39JAI=";
  };

  buildInputs = [ libX11 libXft libXinerama ];

  makeFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "A dmenu rip-off with contextual completion";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
  };
}
