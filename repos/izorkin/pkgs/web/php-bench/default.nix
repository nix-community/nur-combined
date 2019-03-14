{ stdenv, fetchFromGitHub}:

stdenv.mkDerivation rec {
  version = "1.0.32";
  name = "php-simple-benchmark-script-${version}";

  src = fetchFromGitHub {
    owner = "rusoft";
    repo = "php-simple-benchmark-script";
    rev = "v${version}";
    sha256 = "1ncngkgrzsa5nsj1zskqm34xx14kgmjgmlhlidys3nchslsjkza6";
  };

  phases = [ "installPhase" ];

  installPhase = ''
    install -Dm0444 ${src}/bench.php $out/bench.php
    install -Dm0444 ${src}/php5.inc $out/php5.inc
    install -Dm0444 ${src}/php7.inc $out/php7.inc
  '';
}

