{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "lacc";
  version = "2021-01-31";

  src = fetchFromGitHub {
    owner = "larmel";
    repo = "lacc";
    rev = "70436fe2e7ba21ce3a8c43decc99f2b4e8cf1c9f";
    sha256 = "0swh28xlmirbz1m3iwgqmcnhi8bvvnjkqcg9bnfzqn5x7lhjpr1v";
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
