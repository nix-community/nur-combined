{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "lacc";
  version = "2021-05-20";

  src = fetchFromGitHub {
    owner = "larmel";
    repo = pname;
    rev = "b53f338f6cb22349ad24945c7be61b9c2f08250d";
    hash = "sha256-nOWX6Er2KtzZsWDRv8rwBSTLJZ4XnL+YxdSw2nGV1bs=";
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
