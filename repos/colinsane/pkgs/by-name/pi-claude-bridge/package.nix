{
  buildNpmPackage,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
buildNpmPackage (finalAttrs: {
  pname = "pi-claude-bridge";
  version = "0.6.3";

  src = fetchFromGitHub {
    owner = "elidickinson";
    repo = "pi-claude-bridge";
    tag = "v${finalAttrs.version}";
    hash = "sha256-l1j6n4koT0XyB9R5h6mBmPzfTpANljfziYHC6g4TPyk=";
    postFetch = ''
      sed -i $out/package.json \
        -e '/"@earendil-works\/pi-ai": /d' \
        -e '/"@earendil-works\/pi-coding-agent": /d' \
        -e '/"@earendil-works\/pi-tui": /d'
    '';
  };

  npmDepsFetcherVersion = 2;

  npmDepsHash = "sha256-dxDWzHsYJb5ZT/4/urvp4AJPralO13uAA2qWJwa/8yA=";

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
