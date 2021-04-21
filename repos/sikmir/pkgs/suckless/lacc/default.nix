{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "lacc";
  version = "2021-04-21";

  src = fetchFromGitHub {
    owner = "larmel";
    repo = "lacc";
    rev = "f6ab3973d44ce79e469c4c3dc770a8b2e7a5543f";
    sha256 = "sha256-L9EW7Zl5PxOIGJwSwhq1gvAkN8fbpHg7gSbtTzuBHSE=";
  };

  installFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "A simple, self-hosting C compiler";
    homepage = src.meta.homepage;
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = [ maintainers.sikmir ];
  };
}
