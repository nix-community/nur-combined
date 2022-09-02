{ lib, stdenv, fetchFromGitHub, pkg-config, xorg }:

stdenv.mkDerivation rec {
  pname = "sdorfehs";
  version = "1.1";

  src = fetchFromGitHub {
    owner = "jcs";
    repo = "sdorfehs";
    rev = "v${version}";
    hash = "sha256-efid6lRa8CTD+xObbop68hti5WRJReyKW57AmN7DS90=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = with xorg; [ libX11 libXft libXrandr libXtst libXi ];

  installFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "A tiling window manager";
    inherit (src.meta) homepage;
    license = licenses.gpl2Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
}
