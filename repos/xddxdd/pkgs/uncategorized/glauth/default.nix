{
  lib,
  sources,
  buildGoModule,
}:
buildGoModule (finalAttrs: {
  inherit (sources.glauth) pname version src;
  vendorHash = "sha256-Lijy0LFy0PgWogdzYRNPFOkLym6Gf9qG4R+Bm91eYJg=";

  overrideModAttrs = _: {
    buildPhase = ''
      go work vendor -e -v
    '';
  };

  doCheck = false;

  meta = {
    changelog = "https://github.com/glauth/glauth/releases/tag/v${finalAttrs.version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Lightweight LDAP server for development, home use, or CI";
    homepage = "https://github.com/glauth/glauth";
    license = lib.licenses.mit;
    mainProgram = "glauth";
  };
})
