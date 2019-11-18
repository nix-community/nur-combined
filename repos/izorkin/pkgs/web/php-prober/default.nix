{ stdenv, fetchFromGitHub}:

stdenv.mkDerivation rec {
  version = "2.4.0";
  pname = "php-x-prober";

  src = fetchFromGitHub {
    owner = "kmvan";
    repo = "x-prober";
    rev = "${version}";
    sha256 = "0arbqdbb40f6spvcaj38dkww4a88yzdbqx3dwz3jzr3x1s7ywx9d";
  };

  phases = [ "installPhase" ];

  installPhase = ''
    install -Dm0444 ${src}/dist/prober.php $out/prober.php
  '';
}

