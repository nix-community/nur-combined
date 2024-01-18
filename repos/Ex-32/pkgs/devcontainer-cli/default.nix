{ lib
, fetchFromGitHub
, fetchYarnDeps
, mkYarnPackage
}:

mkYarnPackage rec {
  pname = "devcontainers";
  version = "0.56.0";

  src = fetchFromGitHub {
    owner = "devcontainers";
    repo = "cli";
    rev = "v${version}";
    hash = "sha256-PQQRjefXaTyVQkUD9a5CZCn1ftmVB0fIW8PvLC0Wqqo=";
  };

  yarnLock = "${src}/yarn.lock";
  packageJSON = ./package.json;

  offlineCache = fetchYarnDeps {
    inherit yarnLock;
    hash = "sha256-puKgUp24IdbAKaBayFxVgIiS4vZHSMVjC+WdUS7yvbs=";
  };

  buildPhase = ''
    runHook preBuild

    yarn --offline compile-prod

    runHook postBuild
  '';

  meta = {
    homepage = "https://github.com/devcontainers/cli";
    description = "A reference implementation devcontainers";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
}
