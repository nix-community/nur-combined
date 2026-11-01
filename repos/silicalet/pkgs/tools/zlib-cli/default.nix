{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "zlib-cli";
  version = "0.0.12";

  src = fetchFromGitHub {
    owner = "heartleo";
    repo = "zlib";
    tag = "v${finalAttrs.version}";
    hash = "sha256-IQ/KQSKlG4XFbLsO85GznccF+Qp2PPaFoL6mwARBxZQ=";
  };

  vendorHash = "sha256-qXzhQI8LCMnVi5Mu1a8QHPhSyzHeqxQEN0wfb0tlTms=";

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
