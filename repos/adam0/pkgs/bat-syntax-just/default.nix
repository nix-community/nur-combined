{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation {
  pname = "bat-syntax-just";
  version = "4148-1.1.5-unstable-2025-05-08";

  src = fetchFromGitHub {
    owner = "nk9";
    repo = "just_sublime";
    rev = "f42cdb012b6033035ee46bfeac1ecd7dca460e55";
    hash = "sha256-VxI5BPrNVOwIRwdZKm8OhTuXCVKOdG8OGKiCne9cwc8=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    cp Syntax/Just.sublime-syntax "$out/Just.sublime-syntax"

    runHook postInstall
  '';

  dontBuild = true;

  meta = with lib; {
    description = "Just syntax definition for bat";
    homepage = "https://github.com/nk9/just_sublime";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
