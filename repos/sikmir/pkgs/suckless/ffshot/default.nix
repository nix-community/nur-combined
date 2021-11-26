{ lib, stdenv, fetchFromGitHub, xorg }:

stdenv.mkDerivation rec {
  pname = "ffshot";
  version = "2020-05-16";

  src = fetchFromGitHub {
    owner = "shinyblink";
    repo = pname;
    rev = "853b1eb3181affde1b56d6e364fe201f8260d0d0";
    hash = "sha256-sSIpo0JJqJL8BbWDphAEosyfppFd6P+P+vGrA5m1gV8=";
  };

  buildInputs = [ xorg.xcbutil xorg.xcbutilimage ];

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
