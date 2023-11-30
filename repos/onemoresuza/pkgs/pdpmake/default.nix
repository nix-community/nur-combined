{
  fetchFromGitHub,
  lib,
  stdenv,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "pdpmake";
  version = "1.4.1-unstable-2023-11-17";
  src = fetchFromGitHub {
    owner = "rmyorston";
    repo = "pdpmake";
    rev = "11d61873ac250d88e5a708decd1ed7fe3b45982c";
    hash = "sha256-FE+adKoWL/4b5X9ffqFuMQPk75QV7cSuxnEpMVLoDPI=";
  };

  # Must instruct nix's checkPhase, since `check` is a valid target.
  checkTarget = "test";

  installFlags = [
    "PREFIX=${placeholder "out"}"
  ];

  doCheck = true;

  enableParallelBuilding = true;

  meta = with lib; {
    description = "A Public domain POSIX make";
    homepage = "https://frippery.org/make/";
    changelog = "https://frippery.org/make/release-notes/current.html";
    license = licenses.unlicense;
    platforms = platforms.unix;
    mainProgram = "pdpmake";
  };
})
