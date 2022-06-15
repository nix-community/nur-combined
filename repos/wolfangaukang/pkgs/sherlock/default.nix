{ lib, stdenv, fetchFromGitHub, python3, makeWrapper }:

let
  pythonEnv = python3.withPackages (pkg: with pkg; [
    certifi
    colorama
    pysocks
    requests
    requests-futures
    stem
    torrequest
  ]);

in stdenv.mkDerivation {
  pname = "sherlock";
  version = "unstable-2022-06-04";

  src = fetchFromGitHub {
    owner = "sherlock-project";
    repo = "sherlock";
    rev = "9db8c213ffdad873380c9de41c142923ba0dc260";
    sha256 = "sha256-0/toTz5qLedWdXfh80j6yxH3iXGxboys6mKOjka/nUQ=";
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
