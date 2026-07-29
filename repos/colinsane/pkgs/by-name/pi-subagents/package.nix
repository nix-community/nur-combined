{
  buildNpmPackage,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
buildNpmPackage (finalAttrs: {
  pname = "pi-subagents";
  version = "0.37.2";

  src = fetchFromGitHub {
    owner = "nicobailon";
    repo = "pi-subagents";
    tag = "v${finalAttrs.version}";
    hash = "sha256-E6pk35MhwkEa1e+Egp5hhijpy5juIq2vEdayRoqdLDk=";
  };

  npmDepsFetcherVersion = 2;

  npmDepsHash = "sha256-oy4mfpYS3y1eroEbTakxhZsqCwUK69WhnCbs3mmp064=";

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

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Pi extension for delegating tasks to subagents with chains, parallel execution, and TUI clarification";
    homepage = "https://github.com/nicobailon/pi-subagents";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
