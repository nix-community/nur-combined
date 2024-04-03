{
  lib,
  fetchFromGitHub,
  fetchYarnDeps,
  mkYarnPackage,
}:
mkYarnPackage rec {
  pname = "devcontainers";
  version = "0.58.0";

  src = fetchFromGitHub {
    owner = "devcontainers";
    repo = "cli";
    rev = "v${version}";
    hash = "sha256-pnhyyTJMSlTdMsSFzbmZ6SkGdbfr9qCIkrBxxSM42UE=";
  };

  yarnLock = "${src}/yarn.lock";
  packageJSON = ./package.json;

  offlineCache = fetchYarnDeps {
    inherit yarnLock;
    hash = "sha256-Wy0UP8QaQzZ1par7W5UhnRLc5DF2PAif0JIZJtRokBk=";
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
