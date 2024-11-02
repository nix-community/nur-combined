{
  sources,
  lib,
  buildGoModule,
}:
buildGoModule {
  inherit (sources.ldap-auth-proxy) pname version src;
  vendorHash = "sha256-drLTMaRelaz36ORl1qKndGYN2i6qRgJxy2D+wTDzmWA=";

  postPatch = ''
    cp ${./go.mod} go.mod
    cp ${./go.sum} go.sum
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Simple drop-in HTTP proxy for transparent LDAP authentication which is also a HTTP auth backend";
    homepage = "https://github.com/pinepain/ldap-auth-proxy";
    license = lib.licenses.mit;
  };
}
