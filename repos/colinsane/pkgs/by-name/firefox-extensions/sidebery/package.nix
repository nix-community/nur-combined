{
  buildNpmPackage,
  fetchFromGitHub,
  gitUpdater,
  lib,
  wrapFirefoxAddonsHook,
}:
buildNpmPackage (finalAttrs: {
  pname = "sidebery";
  version = "5.5.2";
  src = fetchFromGitHub {
    owner = "mbnuqw";
    repo = "sidebery";
    rev = "v${finalAttrs.version}";
    hash = "sha256-V77H6DfLW1Xy3kdjtCSTptfagxo0A6Syv+c3Zm3fJvc=";
  };

  npmDepsHash = "sha256-3EyPq9iFh2eidsRMCU4EUpL0ezRASFEJ7jBtvEMcg3M=";

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
})
