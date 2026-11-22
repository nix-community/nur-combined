{
  fetchFromGitHub,
  lib,
  mkPiExtension,
  nix-update-script,
}:
mkPiExtension (finalAttrs: {
  pname = "pi-subagents";
  version = "0.89.2";

  src = fetchFromGitHub {
    owner = "nicobailon";
    repo = "pi-subagents";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6XHZ/+KPcx2AcVB2TY9V49Ticw5NbHU4RML7lJ9OsdU=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-D9Z0EhCesSxAYCgYG7GACbj6FRqGGKH8ApwUWmy5W2M=";

  dontNpmBuild = true; # package.json defines no build script

  postInstall = ''
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
    platforms = lib.platforms.linux;
  };
})
