{
  lib,
  sources,
  buildGoModule,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  inherit (sources.glauth) pname version src;
  vendorHash = "sha256-Lijy0LFy0PgWogdzYRNPFOkLym6Gf9qG4R+Bm91eYJg=";

  postPatch = ''
    substituteInPlace v2/internal/version/const.go \
      --replace-fail '"v2.3.1"' '"${finalAttrs.version}"'
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
