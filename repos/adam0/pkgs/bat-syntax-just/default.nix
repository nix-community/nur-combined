{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  stdenvNoCC,
  # keep-sorted end
}:
stdenvNoCC.mkDerivation {
  pname = "bat-syntax-just";
  version = "4148-1.1.7-unstable-2026-04-12";

  src = fetchFromGitHub {
    owner = "nk9";
    repo = "just_sublime";
    rev = "2dcc60286d1af6a4c6c2c03d50bc03230dc56ce3";
    hash = "sha256-XlxItYVL9I612DhfCGHiUdv6U6Nv9LOlEbJVf1zTwPg=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    cp Syntax/Just.sublime-syntax "$out/Just.sublime-syntax"

    runHook postInstall
  '';

  dontBuild = true;

  meta = with lib; {
    # keep-sorted start
    description = "Just syntax definition for bat";
    homepage = "https://github.com/nk9/just_sublime";
    license = licenses.mit;
    platforms = platforms.all;
    # keep-sorted end
  };
}
