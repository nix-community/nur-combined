{
  fetchFromGitHub,
  lib,
  mkPiExtension,
  nix-update-script,
}:
mkPiExtension (finalAttrs: {
  pname = "pi-subagents";
  version = "0.76.1";

  src = fetchFromGitHub {
    owner = "nicobailon";
    repo = "pi-subagents";
    tag = "v${finalAttrs.version}";
    hash = "sha256-D+JOBUu/RsYMcG+Cj5my9LYXmzzq9bEP0fCbZEEKGLI=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-GPk3Laq4lu8l83goXcZY2jGqguF1tgpOtvVBObDtM3E=";

  dontNpmBuild = true;  # package.json defines no build script

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
  };
})
