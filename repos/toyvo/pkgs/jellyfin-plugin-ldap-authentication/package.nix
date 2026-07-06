{
  lib,
  stdenv,
  fetchurl,
  unzip,
  ...
}:

stdenv.mkDerivation rec {
  pname = "ldap-authentication";
  version = "23.0.0.0";

  src = fetchurl {
    url = "https://repo.jellyfin.org/files/plugin/ldap-authentication/ldap-authentication_${version}.zip";
    hash = "sha256-lS4z+o06xRLMtcHi4cZVy7GVfkH6HwC9bM8wduBGdEY=";
  };

  nativeBuildInputs = [ unzip ];

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/
    unzip $src -d $out/
  '';

  meta = with lib; {
    description = "LDAP Authentication plugin for Jellyfin";
    homepage = "https://github.com/jellyfin/jellyfin-plugin-ldapauth";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ toyvo ];
    platforms = platforms.all;
  };
}
