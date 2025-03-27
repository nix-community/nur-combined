{ lib
, buildNpmPackage
, fetchFromGitHub
, gitUpdater
}:
buildNpmPackage rec {
  pname = "sidebery";
  version = "5.3.3";
  src = fetchFromGitHub {
    owner = "mbnuqw";
    repo = "sidebery";
    rev = "v${version}";
    hash = "sha256-wJqEuThoU5s5tYI3bpCBF5ADbLv8qeG3dDbOdL6eDoA=";
  };

  npmDepsHash = "sha256-YRfKI61RPvRUdgUElGgPolYNiUmd7S7uV2Fyb+ThOCM=";

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
