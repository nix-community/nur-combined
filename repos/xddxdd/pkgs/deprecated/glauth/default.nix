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

  meta = {
    changelog = "https://github.com/glauth/glauth/releases/tag/v${version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Lightweight LDAP server for development, home use, or CI";
    homepage = "https://github.com/glauth/glauth";
    license = lib.licenses.mit;
    knownVulnerabilities = [
      "${pname} is available in nixpkgs by a different maintainer"
    ];
    mainProgram = "glauth";
  };
}
