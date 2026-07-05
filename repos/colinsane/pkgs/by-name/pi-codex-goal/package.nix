{
  buildNpmPackage,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
buildNpmPackage (finalAttrs: {
  pname = "pi-codex-goal";
  version = "0.1.33";

  src = fetchFromGitHub {
    owner = "fitchmultz";
    repo = "pi-codex-goal";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Eavr1VdvdI8iDrcP1JodZYUv1hIjSYhoy3Mr65pnIGY=";
    postFetch = ''
      sed -i $out/package.json \
        -e '/"@earendil-works\/pi-ai": "*"/d' \
        -e '/"@earendil-works\/pi-coding-agent": "*"/d'
    '';
  };

  npmDepsFetcherVersion = 2;

  npmDepsHash = "sha256-ZJK8bu5wQc8mpH1OBbLKZKirXa1LaOGqjUlPbVzN4xs=";

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  postInstall = ''
    mv $out/lib/node_modules/pi-codex-goal/* $out
    rm $out/lib/node_modules/pi-codex-goal/.crabboxignore  #< else prevents directory removal
    rmdir $out/lib/node_modules/pi-codex-goal
    rmdir $out/lib/node_modules
    rmdir $out/lib
  '';

  dontNpmBuild = true;  # package.json omits a build script

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--generate-lockfile"
    ];
  };

  meta = {
    description = "Codex-style goal tracking and continuation for pi.";
    homepage = "https://github.com/fitchmultz/pi-codex-goal";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
