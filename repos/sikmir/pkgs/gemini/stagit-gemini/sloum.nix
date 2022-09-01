{ lib, stdenv, libgit2, fetchFromGitea }:

stdenv.mkDerivation rec {
  pname = "stagit-gemini";
  version = "2020-01-18";

  src = fetchFromGitea {
    domain = "git.rawtext.club";
    owner = "sloum";
    repo = "stagit-gemini";
    rev = "2710449792748ac3fefe4ba2500afce1ed193e37";
    hash = "sha256-Tm9jXkGtUNeZNhtHjozWN35z8gL/KcACLvby2Z73vxU=";
  };

  makeFlags = [ "PREFIX=$(out)" ];

  buildInputs = [ libgit2 ];

  meta = with lib; {
    description = "Fork of stagit-gopher that ports the output to gemini";
    inherit (src.meta) homepage;
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = [ maintainers.sikmir ];
  };
}
