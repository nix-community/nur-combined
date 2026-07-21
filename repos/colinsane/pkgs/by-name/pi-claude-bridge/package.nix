{
  buildNpmPackage,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
buildNpmPackage (finalAttrs: {
  pname = "pi-claude-bridge";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "elidickinson";
    repo = "pi-claude-bridge";
    tag = "v${finalAttrs.version}";
    hash = "sha256-RW+wU+wpoTjKJI12y/t61Mxr2oLRSrBoV0ppG5wR3tE=";
    postFetch = ''
      sed -i $out/package.json \
        -e '/"@earendil-works\/pi-ai": /d' \
        -e '/"@earendil-works\/pi-coding-agent": /d' \
        -e '/"@earendil-works\/pi-tui": /d'
    '';
  };

  npmDepsFetcherVersion = 2;

  npmDepsHash = "sha256-IiWBH93JFEBRCQzCIbOhqbTJVyzrQKtDED0myXi/wSE=";

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  dontNpmBuild = true;

  postInstall = ''
    mv $out/lib/node_modules/pi-claude-bridge/* $out
    rmdir $out/lib/node_modules/pi-claude-bridge
    rmdir $out/lib/node_modules
    rmdir $out/lib
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--generate-lockfile"
    ];
  };

  meta = {
    description = "Pi extension that uses Claude Code (via Agent SDK) as a model provider and adds an AskClaude tool";
    homepage = "https://github.com/elidickinson/pi-claude-bridge";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
