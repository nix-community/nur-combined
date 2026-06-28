{
  buildNpmPackage,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:

buildNpmPackage (finalAttrs: {
  pname = "pi-speeed";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "somus";
    repo = "pi-speeed";
    tag = "v${finalAttrs.version}";
    hash = "sha256-kjFJ72Lgav3EXR6QCZ7fm/DsfiGwMYyt4GC8xQEihB0=";
    postFetch = ''
      sed -i $out/package.json \
        -e '/"@earendil-works\/pi-ai": /d' \
        -e '/"@earendil-works\/pi-tui": /d' \
        -e '/"@earendil-works\/pi-coding-agent": /d'
    '';
  };

  npmDepsFetcherVersion = 2;

  npmDepsHash = "sha256-MdFKQ3xZPIIsFco2h9Zshlj/6eFB1c/4sqhG9DcF1TA=";

  # lockfile generated in a pi-speeed checkout using
  # `PATH=$(nix-build ~/nixos/master -A nodejs)/bin:$PATH npm install --package-lock-only`
  postPatch = ''
    cp ${./package-lock.json} package-lock.json

    substituteInPlace package.json --replace-fail \
      '"prepack": "npm run check && npm run typecheck && npm test"' \
      '"prepack": "true"'

    # save/load data to XDG paths, not ~/.pi
    substituteInPlace src/config.ts --replace-fail \
      '.pi/agent/pi-speeed.json' \
      '.config/pi/pi-speeed.json'
    substituteInPlace src/stats.ts --replace-fail \
      '.pi/agent/pi-speeed-stats.json' \
      '.config/pi/pi-speeed-stats.json'
  '';

  dontNpmBuild = true;

  postInstall = ''
    mv $out/lib/node_modules/pi-speeed/* $out
    rmdir $out/lib/node_modules/pi-speeed
    rmdir $out/lib/node_modules
    rmdir $out/lib
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--generate-lockfile"
    ];
  };

  meta = {
    description = "Pi extension that shows assistant output speed with a configurable RunCat speed badge";
    homepage = "https://github.com/somus/pi-speeed";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
