{
  lib,
  buildGoModule,
  sources,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  inherit (sources.ncmm) pname version src;
  vendorHash = "sha256-Tj74DBNOCVRgxWq2W8whj6whQ6uTsptS9bhtqlFFnZg=";

  ldflags = [
    "-s"
    "-w"
  ];

  doCheck = false;

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;
  versionCheckProgramArg = "--version";

  meta = {
    changelog = "https://github.com/3899/ncmm/releases/tag/v${finalAttrs.version}";
    mainProgram = "ncmm";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Command-line assistant for NetEase Cloud Music musicians";
    homepage = "https://github.com/3899/ncmm";
    license = lib.licenses.mit;
  };
})
