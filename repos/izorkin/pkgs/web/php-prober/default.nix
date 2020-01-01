{ stdenv, fetchFromGitHub}:

stdenv.mkDerivation rec {
  version = "3.7";
  pname = "php-x-prober";

  src = fetchFromGitHub {
    owner = "kmvan";
    repo = "x-prober";
    rev = "${version}";
    sha256 = "1ynavmclwlmd8xnwimrdk8dr5ckwflm2ylgawnn0shy7q7gsxn49";
  };

  phases = [ "installPhase" ];

  installPhase = ''
    install -Dm0444 ${src}/dist/prober.php $out/prober.php
  '';
}

