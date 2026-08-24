{
  fetchFromGitHub,
  lib,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "tel42verifier";
  version = "0.0.3";
  src = fetchFromGitHub {
    owner = "strexp";
    repo = "tel42verifier";
    tag = "v0.0.3";
    hash = "sha256-WfJxlE6Xg1MoLIQdhznuh96T0Yi3N/AuFWjrYAe3fQA=";
  };
  vendorHash = "sha256-kS1oS7I1jGTJn1jpId8MwsPd/v+0NOpayUNWfZZHaRQ=";

  subPackages = [ "./cmd/tel42verifier" ];

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
  ];

  nativeInstallCheckInputs = [
    versionCheckHook
  ];
  doInstallCheck = true;
  versionCheckProgramArg = "-version";

  passthru.updateScript = nix-update-script { };
  meta = {
    description = "Multi-domain ENUM-based Caller ID verifier for Asterisk";
    homepage = "https://github.com/strexp/tel42verifier";
    license = lib.licenses.mit;
    mainProgram = "tel42verifier";
    maintainers = with lib.maintainers; [ xddxdd ];
  };
})
