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
  version = "unstable-2022-05-05";

  src = fetchFromGitHub {
    owner = "sherlock-project";
    repo = "sherlock";
    rev = "296f646e2406ed83ba43ba1a22bf5d84ddfe09cb";
    sha256 = "sha256-35Z0W+4na4cVIfqQl2Tj7flnQq7f+1dCWZm9MCegofA=";
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
