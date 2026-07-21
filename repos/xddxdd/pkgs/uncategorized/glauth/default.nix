{
  lib,
  sources,
  buildGoModule,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  inherit (sources.glauth) pname src;
  version = lib.removePrefix "GLAuth-v" sources.glauth.version;
  vendorHash = "sha256-Lijy0LFy0PgWogdzYRNPFOkLym6Gf9qG4R+Bm91eYJg=";

  postPatch = ''
    rm -f v2/pkg/server/embed_sqlite.go
  '';

  overrideModAttrs = _: {
    buildPhase = ''
      go work vendor -e -v
    '';
  };

  ldflags = [
    "-s"
    "-w"
  ];

  doCheck = false;

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;
  versionCheckProgramArg = "--version";

  meta = {
    changelog = "https://github.com/glauth/glauth/releases/tag/v${finalAttrs.version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Lightweight LDAP server for development, home use, or CI";
    homepage = "https://github.com/glauth/glauth";
    license = lib.licenses.mit;
    mainProgram = "glauth";
  };
})
