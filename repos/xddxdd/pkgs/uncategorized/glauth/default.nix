{
  lib,
  sources,
  buildGoModule,
}:
buildGoModule rec {
  inherit (sources.glauth) pname version src;
  vendorHash = "sha256-MfauZRufl3kxr1fqatxTmiIvLJ+5JhbpSnbTHiujME8=";
  modRoot = "v2";

  preBuild = ''
    export GOWORK=off
    export subPackages="."
  '';

  doCheck = false;

  meta = with lib; {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Lightweight LDAP server for development, home use, or CI";
    homepage = "https://github.com/glauth/glauth";
    license = licenses.mit;
  };
}
