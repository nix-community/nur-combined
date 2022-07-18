{ stdenv, fetchFromGitHub}:

stdenv.mkDerivation rec {
  pname = "php-simple-benchmark-script";
  version = "1.0.37";

  src = fetchFromGitHub {
    owner = "rusoft";
    repo = "php-simple-benchmark-script";
    rev = "v${version}";
    sha256 = "0675llxr8hgrn4mggr9s10j17k63scspd5cgcqhgykzvz9560mnn";
  };

  phases = [ "installPhase" ];

  installPhase = ''
    install -Dm0444 ${src}/bench.php $out/bench.php
    install -Dm0444 ${src}/php5.inc $out/php5.inc
    install -Dm0444 ${src}/php7.inc $out/php7.inc
  '';
}

