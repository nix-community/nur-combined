{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "lacc";
  version = "2021-07-29";

  src = fetchFromGitHub {
    owner = "larmel";
    repo = pname;
    rev = "ac8c693a8d70c23ef72b81112e7f67682b384db4";
    hash = "sha256-mvnkZ2+mDC9Imwpx4TAeFrnagUibE4acAGV8pwEmZlA=";
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
