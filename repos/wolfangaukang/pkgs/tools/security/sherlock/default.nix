{ lib, stdenv, fetchFromGitHub, python3, makeWrapper }:

let
  pythonEnv = python3.withPackages (pkg: with pkg; [
    certifi
    colorama
    pandas
    pysocks
    requests
    requests-futures
    stem
    torrequest
  ]);

in stdenv.mkDerivation {
  pname = "sherlock";
  version = "unstable-2022-10-21";

  src = fetchFromGitHub {
    owner = "sherlock-project";
    repo = "sherlock";
    rev = "8a75dcff4b5d471f0ba1c5c0fee958d47edb4eba";
    sha256 = "sha256-U3sINusYE48t0jcvsUwhmUh4hdEXy6pn/SfgR7w52xw=";
  };

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [ pythonEnv ];

  installPhase = ''
    mkdir -p $out/opt/
    cp -r sherlock $out/opt/
    makeWrapper ${pythonEnv}/bin/python3 $out/bin/sherlock \
      --add-flags "$out/opt/sherlock/sherlock.py"
  '';

  # All tests require access to the net

  meta = with lib; {
    description = "Hunt down social media accounts by username across social networks";
    homepage = "https://github.com/sherlock-project/sherlock";
    maintainers = with maintainers; [ wolfangaukang ];
    platforms = platforms.unix;
    licenses = licenses.mit;
    mainProgram = "sherlock";
  };
}
