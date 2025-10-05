{
  lib,
  stdenv,
  libgit2,
  fetchFromGitea,
}:

stdenv.mkDerivation {
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

  meta = {
    description = "Fork of stagit-gopher that ports the output to gemini";
    homepage = "https://git.rawtext.club/sloum/stagit-gemini";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
