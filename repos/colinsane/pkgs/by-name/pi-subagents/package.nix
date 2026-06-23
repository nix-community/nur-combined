{
  buildNpmPackage,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
buildNpmPackage (finalAttrs: {
  pname = "pi-subagents";
  version = "0.30.0";

  src = fetchFromGitHub {
    owner = "nicobailon";
    repo = "pi-subagents";
    tag = "v${finalAttrs.version}";
    hash = "sha256-a9jE5abF54ZDTUN6GajiNEPu4qVqjCJ7MRTTAA8nNiE=";
    # upstream omits the version pin for pi-* dependencies, expecting pi to already be present.
    # patch out the deps onto pi *here*, so that nix-update-script can generate a correct lockfile.
    postFetch = ''
      sed -i $out/package.json \
        -e '/"@earendil-works\/pi-agent-core": "/d' \
        -e '/"@earendil-works\/pi-ai": "/d' \
        -e '/"@earendil-works\/pi-coding-agent": "/d'
    '';
  };

  npmDepsFetcherVersion = 2;

  npmDepsHash = "sha256-8k4+YRIRp0oYXsSI9TccrJZiwK8fyZWDvUawgqeXB8c=";

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  dontNpmBuild = true;

  postInstall = ''
    mv $out/lib/node_modules/pi-subagents/* $out
    rmdir $out/lib/node_modules/pi-subagents
    rmdir $out/lib/node_modules
    rmdir $out/lib

    # the binary is an "installer", not useful.
    rm $out/bin/pi-subagents
    rmdir $out/bin
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--generate-lockfile"
    ];
  };

  meta = {
    description = "Pi extension for delegating tasks to subagents with chains, parallel execution, and TUI clarification";
    homepage = "https://github.com/nicobailon/pi-subagents";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
