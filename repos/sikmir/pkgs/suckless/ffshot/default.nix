{ lib, stdenv, fetchFromGitHub, xorg }:

stdenv.mkDerivation rec {
  pname = "ffshot";
  version = "2022-05-29";

  src = fetchFromGitHub {
    owner = "shinyblink";
    repo = pname;
    rev = "07d86c717d764690cbb765ea658405f14364556c";
    hash = "sha256-lPHPwieotSgA6qF3EGDZk+lME0rqglOnEreYLk0/oUY=";
  };

  buildInputs = [ xorg.libxcb xorg.xcbutilimage ];

  installFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "farbfeld screenshot utility";
    inherit (src.meta) homepage;
    license = licenses.isc;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
}
