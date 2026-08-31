{
  fetchFromGitHub,
  lib,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "glauth";
  version = "2.5.2";
  src = fetchFromGitHub {
    owner = "glauth";
    repo = "glauth";
    tag = "GLAuth-v${finalAttrs.version}";
    hash = "sha256-LrQmCkWiPSZIW2zxdqIWXL+w+hE3Duu2sM17TDcYmkk=";
  };
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

  passthru.updateScript = nix-update-script { };
  meta = {
    changelog = "https://github.com/glauth/glauth/releases/tag/v${finalAttrs.version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Lightweight LDAP server for development, home use, or CI";
    homepage = "https://github.com/glauth/glauth";
    license = lib.licenses.mit;
    mainProgram = "glauth";
  };
})
