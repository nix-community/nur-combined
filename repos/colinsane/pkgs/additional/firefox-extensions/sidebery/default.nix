{ lib
, buildNpmPackage
, fetchFromGitHub
, gitUpdater
}:
buildNpmPackage rec {
  pname = "sidebery";
  version = "5.2.0";
  src = fetchFromGitHub {
    owner = "mbnuqw";
    repo = "sidebery";
    rev = "v${version}";
    hash = "sha256-83n0aX5mJYf1yYamuM+DelkpOGLRZqkXpTgQMAmMLXI=";
  };

  npmDepsHash = "sha256-wBYjX65Tb3+83NT5625j77qceCADkiS22PsmCdwbJA0=";

  postBuild = ''
    npm run build.ext
  '';

  installPhase = ''
    cp dist/* "$out"
  '';

  passthru = {
    extid = "{3c078156-979c-498b-8990-85f7987dd929}";
    updateScript = gitUpdater {
      rev-prefix = "v";
    };
  };

  meta = {
    homepage = "https://github.com/mbnuqw/sidebery";
    description = "Firefox extension for managing tabs and bookmarks in sidebar";
    maintainer = with lib.maintainers; [ colinsane ];
  };
}
