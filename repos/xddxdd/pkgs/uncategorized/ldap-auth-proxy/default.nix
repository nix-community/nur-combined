{
  sources,
  lib,
  fetchFromGitHub,
  buildGoPackage,
  ...
}:
buildGoPackage {
  inherit (sources.ldap-auth-proxy) pname version src;

  goPackagePath = "github.com/pinepain/ldap-auth-proxy";
  goDeps = ./deps.nix;

  meta = with lib; {
    description = "A simple drop-in HTTP proxy for transparent LDAP authentication which is also a HTTP auth backend.";
    homepage = "https://github.com/pinepain/ldap-auth-proxy";
    license = licenses.mit;
  };
}
