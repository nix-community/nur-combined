{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "lacc";
  version = "2021-12-27";

  src = fetchFromGitHub {
    owner = "larmel";
    repo = pname;
    rev = "0e2a4a0dad2964c9d7cff15824972d32ab0b8440";
    hash = "sha256-argJDjAM6G3eC2uftZjW3ojSdN7zj1rjtwgSux2zAXI=";
  };

  installFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "A simple, self-hosting C compiler";
    inherit (src.meta) homepage;
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = [ maintainers.sikmir ];
  };
}
