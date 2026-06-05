{
  fetchFromGitHub,
  gitUpdater,
  lib,
  buildNpmPackage,
}:
buildNpmPackage (finalAttrs: {
  pname = "pi-simplify";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "MattDevy";
    repo = "pi-extensions";
    tag = "pi-simplify-v${finalAttrs.version}";
    hash = "sha256-0XzYaKGuLzcG31f3aQ65l83DZPbNLI7fg+eJc0s3wo0=";
  };

  npmDepsHash = "sha256-lM/wfWBWEV5C7SOjEJ4IxN0kOa+EoHmLTQdqDGThVvY=";

  buildPhase = ''
    npm run build --workspace=pi-simplify
  '';

  # package.json sets `dist/...` as the entry point, so we need to install that.
  # this also installs all the `src/...`: not necessary, but oh well.
  installPhase = ''
    runHook preInstall
    cp -R packages/pi-simplify $out
    runHook postInstall
  '';

  passthru.updateScript = gitUpdater {
    rev-prefix = "pi-simplify-v";
  };

  meta = {
    description = "A Pi extension that reviews recently changed code for clarity, consistency, and maintainability improvements.";
    homepage = "https://github.com/MattDevy/pi-extensions/tree/main/packages/pi-simplify";
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
