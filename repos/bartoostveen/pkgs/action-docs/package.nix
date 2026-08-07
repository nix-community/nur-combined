{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  yarnConfigHook,
  yarnBuildHook,
  yarnInstallHook,
  nodejs,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "action-docs";
  version = "2.5.1-unstable-2025-06-13";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "npalm";
    repo = "action-docs";
    rev = "4e97acde45ed62643b4c80532801313d2b62c9ea";
    hash = "sha256-dSR6zOw0nJWMkv3AA6mGeky/27/wiknMqXcfO0Lhn24=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-yIkyydNOV3cjOiQ/sdWxlhxySnE6GyvcljWP+fgp6+U=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    yarnInstallHook
    nodejs
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch=main" ]; };

  meta = {
    description = "Generate docs for GitHub actions";
    homepage = "https://github.com/npalm/action-docs";
    changelog = "https://github.com/npalm/action-docs/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bartoostveen ];
    mainProgram = "action-docs";
    platforms = lib.platforms.all;
  };
})
