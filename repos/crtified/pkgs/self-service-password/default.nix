{ stdenv, fetchFromGitHub, fetchpatch, optipng, smarty3 }:

stdenv.mkDerivation rec {
  pname = "self-service-password";
  version = "1.5.2";

  src = fetchFromGitHub {
    owner = "ltb-project";
    repo = "self-service-password";
    rev = "v${version}";
    hash = "sha256-1mhk/njYIqcurDD6EO/kff/RLUBMO4UkaYVIECuKc/I=";
  };

  buildInputs = [ optipng ];
  installInputs = [ smarty3 ];

  installPhase = ''
    find . -name '*.png' -print0 | xargs -0 optipng -quiet -force -fix

    mkdir -p $out/share/self-service-password
    cp -ra . $out/share/self-service-password

    sed -i 's|/usr/share/php/smarty3|'${smarty3}'|g' $out/share/self-service-password/conf/config.inc.php
    ln -s /etc/self-service-password/config.inc.local.php $out/share/self-service-password/conf/config.inc.local.php
  '';
}
