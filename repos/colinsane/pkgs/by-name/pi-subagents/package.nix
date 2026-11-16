{
  fetchFromGitHub,
  lib,
  mkPiExtension,
  nix-update-script,
}:
mkPiExtension (finalAttrs: {
  pname = "pi-subagents";
  version = "0.88.0";

  src = fetchFromGitHub {
    owner = "nicobailon";
    repo = "pi-subagents";
    tag = "v${finalAttrs.version}";
    hash = "sha256-DPeu8UEl0Oq+m3YirA4vXOaDmyyIVMkxBzMXEWrmVHo=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-u7gav2zboUp8XI7EVXIh1kO04xpv1CSgcU8psj65TAk=";

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
