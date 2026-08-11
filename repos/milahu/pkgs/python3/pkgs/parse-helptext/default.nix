{ lib
, stdenv
, fetchFromGitHub
, python3
}:

stdenv.mkDerivation rec {
  pname = "parse-helptext";
  version = "unstable-2024-04-19";

  src = fetchFromGitHub {
    owner = "milahu";
    repo = "parse-helptext";
    rev = "37b98eafbe2503b64affcd986c95d00cf7f9aaa8";
    hash = "sha256-3888mLsw1SWPal6FrdD09shen57s346xm28JMIUgEdQ=";
  };

  buildInputs = [
    python3
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp parse_helptext.py $out/bin/parse-helptext
  '';

  meta = with lib; {
    description = "Parse getopt-style help texts from somecommand --help";
    homepage = "https://github.com/milahu/parse-helptext";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ ];
    mainProgram = "parse-helptext";
    platforms = platforms.all;
  };
}
