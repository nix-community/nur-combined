{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  yarnConfigHook,
  yarnBuildHook,
  yarnInstallHook,
  nodejs,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "har-extractor";
  version = "1.1.2";

  src = fetchFromGitHub {
    owner = "azu";
    repo = "har-extractor";
    # tag = "v${finalAttrs.version}";
    # https://github.com/azu/har-extractor/pull/19
    rev = "d05241be19b71f3f6e79f72566a5903628ca8404";
    hash = "sha256-yIyPcVVGmDlOV4fRgO7P8EEdtbGfWHfF4T+s04lXefo=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = finalAttrs.src + "/yarn.lock";
    hash = "sha256-AAF9wnSXj0RadJVR5orDcpJMlQtVNnQtxcHN2sHAWCo=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    yarnInstallHook
    # Needed for executing package.json scripts
    nodejs
  ];

  meta = {
    description = "A CLI that extract har file to directory";
    homepage = "https://github.com/azu/har-extractor";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "har-extractor";
    platforms = lib.platforms.all;
  };
})
