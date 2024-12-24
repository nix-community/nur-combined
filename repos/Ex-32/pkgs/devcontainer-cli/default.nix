{
  lib,
  fetchFromGitHub,
  fetchYarnDeps,
  mkYarnPackage,
}:
mkYarnPackage rec {
  pname = "devcontainers";
  version = "0.72.0";

  src = fetchFromGitHub {
    owner = "devcontainers";
    repo = "cli";
    rev = "v${version}";
    hash = "sha256-3rSWD6uxwcMQdHBSmmAQ0aevqevVXINigCj06jjEcRc=";
  };

  yarnLock = "${src}/yarn.lock";
  packageJSON = ./package.json;

  offlineCache = fetchYarnDeps {
    inherit yarnLock;
    hash = "sha256-KSVr6RlBEeDAo8D+7laTN+pSH8Ukl6WTpeAULuG2fq8=";
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
