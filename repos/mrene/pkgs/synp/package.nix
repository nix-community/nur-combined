{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  yarnConfigHook,
  yarnInstallHook,
  nodejs,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "synp";
  version = "1.9.14";

  src = fetchFromGitHub {
    owner = "imsnif";
    repo = "synp";
    rev = "v${finalAttrs.version}";
    hash = "sha256-OIDW5cAlFoTtjGnz7jEjH3MNPaStkbtdVBF2Y7KiiyI=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = finalAttrs.src + "/yarn.lock";
    hash = "sha256-e0cYS2ejujULNV7uQ6iW5N0ZfvUmk0mQ9nv0uNl4izU=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnInstallHook
    nodejs
  ];

  # No build step needed - synp is pure JavaScript
  dontYarnBuild = true;

  meta = {
    description = "Convert yarn.lock to package-lock.json and vice versa";
    homepage = "https://github.com/imsnif/synp";
    changelog = "https://github.com/imsnif/synp/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "synp";
    platforms = lib.platforms.all;
  };
})
