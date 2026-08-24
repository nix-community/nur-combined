{
  fetchFromGitHub,
  lib,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "ncmm";
  version = "1.1.15";
  src = fetchFromGitHub {
    owner = "3899";
    repo = "ncmm";
    tag = "v1.1.15";
    hash = "sha256-0QnSRMTAzxzCi05Wc52TwFdqo1KqrX59hxzbJk+zQ6o=";
  };
  vendorHash = "sha256-dYGMbXaPARioUHlNcQCtCM8q79g66m9utnAS7Bdyrk4=";

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
    changelog = "https://github.com/3899/ncmm/releases/tag/v${finalAttrs.version}";
    mainProgram = "ncmm";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Command-line assistant for NetEase Cloud Music musicians";
    homepage = "https://github.com/3899/ncmm";
    license = lib.licenses.mit;
  };
})
