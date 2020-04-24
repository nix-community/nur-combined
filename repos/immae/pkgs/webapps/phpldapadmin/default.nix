{ config ? "/etc/phpldapadmin/config.php", fetchurl, fetchFromGitHub, stdenv, optipng }:
stdenv.mkDerivation rec {
  version = "1.2.5";
  name = "phpldapadmin-${version}";
  src = fetchFromGitHub {
    owner = "leenooks";
    repo = "phpLDAPadmin";
    rev = "8f4ced96f9c63a09510a5bccb2189a8b92fb29ba";
    sha256 = "1x6xc3xbvw3aj46i5ds06a8h6mfljxdv3argxrzz02l541ra6ni7";
  };
  patches = [
    #./ldap-php5_5.patch
    #./ldap-disable-mcrypt.patch
    #./ldap-php7_2.patch
    ./ldap-sort-in-templates.patch
    ./ldap-align-button.patch
    ./ldap-fix-password.patch
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
