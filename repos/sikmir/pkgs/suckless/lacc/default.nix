{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "lacc";
  version = "2022-01-19";

  src = fetchFromGitHub {
    owner = "larmel";
    repo = pname;
    rev = "4decf737574cd195ea5a94f0ba44532e3d7e1476";
    hash = "sha256-NGuP0FU9vmmkPng6ablcRaLKUt8Jy48WDMxjsEbdZDQ=";
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
