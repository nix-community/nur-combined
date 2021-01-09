{ stdenv, fetchFromGitHub}:

stdenv.mkDerivation rec {
  version = "6.6";
  pname = "php-x-prober";

  src = fetchFromGitHub {
    owner = "kmvan";
    repo = "x-prober";
    rev = "${version}";
    sha256 = "1fmymbd3kxgssaq5v01krgn078bjlc4a86lci42dpnazgbmk1lry";
  };

  phases = [ "installPhase" ];

  installPhase = ''
    install -Dm0444 ${src}/dist/prober.php $out/prober.php
  '';
}

