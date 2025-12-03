{
  buildNpmPackage,
  fetchFromGitHub,
  gitUpdater,
  lib,
  wrapFirefoxAddonsHook,
}:
buildNpmPackage rec {
  pname = "sidebery";
  version = "5.4.0";
  src = fetchFromGitHub {
    owner = "mbnuqw";
    repo = "sidebery";
    rev = "v${version}";
    hash = "sha256-Y7Aq+fZPJcYQcJjykyobT5LFanz4TcMSNoJBWgr1w9Q=";
  };

  npmDepsHash = "sha256-vwCi76oUsKVwGKyT5WhqI4KY75ZXg3qH2aITQmnDx0E=";

  nativeBuildInputs = [
    wrapFirefoxAddonsHook
  ];

  postBuild = ''
    npm run build.ext
  '';

  installPhase = ''
    mkdir $out
    cp dist/* $out/$extid.xpi
  '';

  extid = "{3c078156-979c-498b-8990-85f7987dd929}";

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
  };

  meta = {
    homepage = "https://github.com/mbnuqw/sidebery";
    description = "Firefox extension for managing tabs and bookmarks in sidebar";
    maintainer = with lib.maintainers; [ colinsane ];
  };
}
