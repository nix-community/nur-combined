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
  version = "unstable-2023-03-17";

  src = fetchFromGitHub {
    owner = "sherlock-project";
    repo = "sherlock";
    rev = "7b97c3e59f96b7bb3b7301a31002b5157a51a947";
    sha256 = "sha256-PWIywBhbZg6GODzN98fYH4p7CmxVKWKd7Vt9KkHJlgw=";
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
