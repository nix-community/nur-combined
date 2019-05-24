{ config ? "/etc/phpldapadmin/config.php", fetchurl, stdenv, optipng }:
stdenv.mkDerivation rec {
  version = "1.2.3";
  name = "phpldapadmin-${version}";
  src = fetchurl {
    url = "https://downloads.sourceforge.net/project/phpldapadmin/phpldapadmin-php5/${version}/${name}.tgz";
    sha256 = "0n7dhp2a7n1krmnik3pb969jynsmhghmxviivnckifkprv1zijmf";
  };
  patches = [
    ./ldap-php5_5.patch
    ./ldap-disable-mcrypt.patch
    ./ldap-php7_2.patch
    ./ldap-sort-in-templates.patch
    ./ldap-align-button.patch
    ];
  buildInputs = [ optipng ];
  buildPhase = ''
    find -name '*.png' -exec optipng -quiet -force -fix {} \;
  '';
  installPhase = ''
    cp -a . $out
    ln -sf ${config} $out/config/config.php
  '';
}
