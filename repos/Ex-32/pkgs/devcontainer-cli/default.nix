{
  lib,
  fetchFromGitHub,
  fetchYarnDeps,
  mkYarnPackage,
}:
mkYarnPackage rec {
  pname = "devcontainers";
  version = "0.59.1";

  src = fetchFromGitHub {
    owner = "devcontainers";
    repo = "cli";
    rev = "v${version}";
    hash = "sha256-Ic62qLJNDF193tBVbWxnFy+zJ/JJ9f7AAW+fDPPbskc=";
  };

  yarnLock = "${src}/yarn.lock";
  packageJSON = ./package.json;

  offlineCache = fetchYarnDeps {
    inherit yarnLock;
    hash = "sha256-tN7qAvfYmDz5ZtgZL5+ZZtkuxZxvlS9FM3+dGl+daUQ=";
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
