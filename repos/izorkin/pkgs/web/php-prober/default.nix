{ stdenv, fetchFromGitHub}:

stdenv.mkDerivation rec {
  version = "8.6";
  pname = "php-x-prober";

  src = fetchFromGitHub {
    owner = "kmvan";
    repo = "x-prober";
    rev = "${version}";
    sha256 = "sha256-p0k/RSxoeNmKGqTDGpAb/EmKLDFr4hp+Cw91DrPVLKk=";
  };

  phases = [ "installPhase" ];

  installPhase = ''
    install -Dm0444 ${src}/dist/prober.php $out/prober.php
  '';
}

