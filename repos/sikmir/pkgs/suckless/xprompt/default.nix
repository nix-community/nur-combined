{ lib, stdenv, fetchFromGitHub, libX11, libXft, libXinerama }:

stdenv.mkDerivation rec {
  pname = "xprompt";
  version = "2.5.0";

  src = fetchFromGitHub {
    owner = "phillbush";
    repo = "xprompt";
    rev = "v${version}";
    hash = "sha256-pOayKngUlrMY3bFsP4Fi+VsOLKCUQU3tdkZ+0OY1SCo=";
  };

  buildInputs = [ libX11 libXft libXinerama ];

  makeFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "A dmenu rip-off with contextual completion";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
}
