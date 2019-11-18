{ stdenv, fetchFromGitHub}:

stdenv.mkDerivation rec {
  version = "3.4";
  pname = "php-x-prober";

  src = fetchFromGitHub {
    owner = "kmvan";
    repo = "x-prober";
    rev = "${version}";
    sha256 = "0zgs8r3hzg0k98qk7nm4m2d68xx0kr18czac1813i1v14kv71gg3";
  };

  phases = [ "installPhase" ];

  installPhase = ''
    install -Dm0444 ${src}/dist/prober.php $out/prober.php
  '';
}

