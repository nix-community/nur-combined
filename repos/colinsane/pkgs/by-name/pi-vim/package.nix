{
  buildNpmPackage,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
buildNpmPackage (finalAttrs: {
  pname = "pi-vim";
  version = "0.14.1";

  src = fetchFromGitHub {
    owner = "lajarre";
    repo = "pi-vim";
    tag = "v${finalAttrs.version}";
    hash = "sha256-xx6PBcSC4V4ixMv9v0wikP7I71M1i9J4iDJCGB+ENDk=";
    # upstream omits the integrity hashes for pi-* dependencies, expecting pi to already be present.
    # patch out the deps onto pi *here*, so that nix-update-script can generate a correct lockfile.
    postFetch = ''
      sed -i $out/package.json \
        -e '/"@earendil-works\/pi-coding-agent": /d' \
        -e '/"@earendil-works\/pi-tui": /d'
    '';
  };

  npmDepsFetcherVersion = 2;

  npmDepsHash = "sha256-NEMzKwseBUHAwLcFjdIJa71d/f4xf447dojwS2n31HQ=";

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  postInstall = ''
    mv $out/lib/node_modules/pi-vim/* $out
    rmdir $out/lib/node_modules/pi-vim
    rmdir $out/lib/node_modules
    rmdir $out/lib
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--generate-lockfile"
    ];
  };

  meta = {
    description = "Modal vim-like editing for Pi's input prompt. Covers the high-frequency 90% command surface.";
    homepage = "https://github.com/lajarre/pi-vim";
    maintainers = with lib.maintainers; [ colinsane ];
    license = lib.licenses.mit;
  };
})
