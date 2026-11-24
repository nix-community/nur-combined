{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "zlib-cli";
  version = "0.0.16";

  src = fetchFromGitHub {
    owner = "heartleo";
    repo = "zlib";
    tag = "v${finalAttrs.version}";
    hash = "sha256-RPzenQ/fxddo46Wzsij+YVqAOomsSN8meXyFwPC2aAA=";
  };

  vendorHash = "sha256-UmHkKNBEf6Phjnd9UwU7kj31JPKtiqxUazQ6Fov+WXU=";

  env.CGO_ENABLED = 0;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/heartleo/zlib/internal/zlib.Version=${finalAttrs.version}"
  ];

  subPackages = [ "cmd/zlib" ];

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;
  versionCheckProgram = "${placeholder "out"}/bin/zlib";
  versionCheckProgramArg = "version";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Command-line client for Z-Library";
    homepage = "https://github.com/heartleo/zlib";
    changelog = "https://github.com/heartleo/zlib/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "zlib";
    platforms = lib.platforms.all;
  };
})
