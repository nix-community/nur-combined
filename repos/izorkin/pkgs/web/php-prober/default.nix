{ stdenv, fetchFromGitHub}:

stdenv.mkDerivation rec {
  version = "3.6";
  pname = "php-x-prober";

  src = fetchFromGitHub {
    owner = "kmvan";
    repo = "x-prober";
    rev = "${version}";
    sha256 = "0w4acgskx1p8ily55jdvabz8sfqk9aq8ahnj60i78n6dq9dp5729";
  };

  phases = [ "installPhase" ];

  installPhase = ''
    install -Dm0444 ${src}/dist/prober.php $out/prober.php
  '';
}

