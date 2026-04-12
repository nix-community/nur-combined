{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  stdenvNoCC,
  # keep-sorted end
}:
stdenvNoCC.mkDerivation {
  pname = "bat-syntax-just";
  version = "4148-1.1.5-unstable-2026-04-11";

  src = fetchFromGitHub {
    owner = "nk9";
    repo = "just_sublime";
    rev = "36f84c22d5ab577c113792052d8debf5b304130e";
    hash = "sha256-9xJQHEDQUQcMDwLmSv5V1+YyMINMSDipEydTtX6U/rc=";
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
