{
  aws-lc,
  fetchFromGitHub,
  lib,
  nix-update-script,
  pkg-config,
  rustPlatform,
  sqlite,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "extenddb";
  version = "0.1.15";
  src = fetchFromGitHub {
    owner = "ExtendDB";
    repo = "extenddb";
    tag = "v${finalAttrs.version}";
    hash = "sha256-HH8xoG3sW1LnTmGJ5Y5VtT3ISFlQL/ZDFLs+J7Dj2Ho=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  cargoHash = "sha256-82kh8Nqk4si72gU66VX1hCymOYG/QJz4SARP/7ASGJM=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    aws-lc
    sqlite
  ];

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;
  versionCheckProgramArg = "--version";

  passthru.updateScript = nix-update-script { };
  meta = {
    changelog = "https://github.com/ExtendDB/extenddb/releases/tag/v${finalAttrs.version}";
    homepage = "https://github.com/ExtendDB/extenddb";
    description = "DynamoDB-compatible API adapter backed by PostgreSQL";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ xddxdd ];
    mainProgram = "extenddb";
  };
})
