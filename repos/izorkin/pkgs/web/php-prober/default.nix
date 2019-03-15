{ stdenv, fetchFromGitHub}:

stdenv.mkDerivation rec {
  version = "2.3.1";
  name = "php-x-prober-${version}";

  src = fetchFromGitHub {
    owner = "kmvan";
    repo = "x-prober";
    rev = "${version}";
    sha256 = "0rpysfzrcmw6a9vh7s2kvwg024b3jaavsfycy30spf409ifpk69x";
  };

  phases = [ "installPhase" ];

  installPhase = ''
    install -Dm0444 ${src}/dist/prober.php $out/prober.php
  '';
}

