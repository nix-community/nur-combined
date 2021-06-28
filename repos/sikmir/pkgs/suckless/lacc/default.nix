{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "lacc";
  version = "2021-06-22";

  src = fetchFromGitHub {
    owner = "larmel";
    repo = pname;
    rev = "d6d56ef90a3258657a41d7b01c0e5546a30b817c";
    hash = "sha256-xcwaZfUeonSwvDEua3FtOEaXcuIhV7apsyJx+RLLnck=";
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
