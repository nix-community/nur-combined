{
  sources,
  lib,
  buildGoModule,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  inherit (sources.tel42verifier) pname version src;

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

  meta = {
    description = "Multi-domain ENUM-based Caller ID verifier for Asterisk";
    homepage = "https://github.com/strexp/tel42verifier";
    license = lib.licenses.mit;
    mainProgram = "tel42verifier";
    maintainers = with lib.maintainers; [ xddxdd ];
  };
})
