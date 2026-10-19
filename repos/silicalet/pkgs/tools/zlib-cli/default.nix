{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "zlib-cli";
  version = "0.0.9";

  src = fetchFromGitHub {
    owner = "heartleo";
    repo = "zlib";
    tag = "v${finalAttrs.version}";
    hash = "sha256-0D2xKuhYz4WDx2KUJYW/dln+ulXi9Sh9z2uvKgciMZQ=";
  };

  vendorHash = "sha256-GE3FXOKnmtpCQQ1+QTyBqimJH2x9jQeT0C5zD9k+PVI=";

  env.CGO_ENABLED = 0;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/heartleo/zlib.Version=${finalAttrs.version}"
    "-X github.com/heartleo/zlib.Commit=v${finalAttrs.version}"
    "-X github.com/heartleo/zlib.Date=unknown"
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
