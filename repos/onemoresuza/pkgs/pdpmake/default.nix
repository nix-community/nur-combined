{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "pdpmake";
  version = "1.4.1";
  src = fetchFromGitHub {
    owner = "rmyorston";
    repo = pname;
    rev = version;
    sha256 = "sha256-N9MT+3nE8To0ktNTPT9tDHkKRrn4XsTYiTeYdBk9VtI=";
  };

  installFlags = [
    "PREFIX=${placeholder "out"}"
  ];

  doCheck = true;
  #
  # Must instruct nix's checkPhase, since `check` is a valid target.
  #
  checkPhase = ''
    make test
  '';

  meta = with lib; {
    description = "A Public domain POSIX make";
    homepage = "https://frippery.org/make/";
    changelog = "https://frippery.org/make/release-notes/current.html";
    license = licenses.unlicense;
    platforms = platforms.unix;
    mainProgram = "pdpmake";
  };
}
