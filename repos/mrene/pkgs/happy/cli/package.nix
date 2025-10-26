{
  lib,
  fetchFromGitHub,
  fetchYarnDeps,
  mkYarnPackage,
}:

mkYarnPackage rec {
  pname = "happy-cli";
  version = "0.11.2";

  src = fetchFromGitHub {
    owner = "slopus";
    repo = "happy-cli";
    rev = "v${version}";
    hash = "sha256-WKzbpxHqE3Dxqy/PDj51tM9+Wl2Pallfrc5UU2MxNn8=";
  };

  offlineCache = fetchYarnDeps {
    yarnLock = "${src}/yarn.lock";
    hash = "sha256-3/qcbCJ+Iwc+9zPCHKsCv05QZHPUp0it+QR3z7m+ssw=";
  };

  buildPhase = ''
    runHook preBuild
    yarn --offline build
    runHook postBuild
  '';

  meta = {
    description = "Happy Coder CLI to connect your local Claude Code to mobile device";
    homepage = "https://github.com/slopus/happy-cli";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mrene ];
    mainProgram = "happy";
    platforms = lib.platforms.unix;
  };
}
