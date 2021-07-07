{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "lacc";
  version = "2021-07-06";

  src = fetchFromGitHub {
    owner = "larmel";
    repo = pname;
    rev = "00d5dcfcb6078dfca728eee0b5ef931c38c29d9b";
    hash = "sha256-F5pfmabT1MCigjybWrhgPLeKSpHckWaMDYhq2J447Is=";
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
