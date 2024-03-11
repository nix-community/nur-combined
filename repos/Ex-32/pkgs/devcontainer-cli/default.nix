{
  lib,
  fetchFromGitHub,
  fetchYarnDeps,
  mkYarnPackage,
}:
mkYarnPackage rec {
  pname = "devcontainers";
  version = "0.57.0";

  src = fetchFromGitHub {
    owner = "devcontainers";
    repo = "cli";
    rev = "v${version}";
    hash = "sha256-qMrcJGI2TL5VHiLfvxIyOT7hFbh9mxMN7g5fBTgJWq8=";
  };

  yarnLock = "${src}/yarn.lock";
  packageJSON = ./package.json;

  offlineCache = fetchYarnDeps {
    inherit yarnLock;
    hash = "sha256-FTu/m32FAJhkiAmJlu/tjxNnht+77MJfhpzYmdJNjcU=";
  };

  buildPhase = ''
    runHook preBuild

    yarn --offline compile-prod

    runHook postBuild
  '';

  meta = {
    homepage = "https://github.com/devcontainers/cli";
    description = "A reference implementation of devcontainers";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
}
