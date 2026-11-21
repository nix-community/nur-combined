{
  buildNpmPackage,
  fetchFromGitHub,
  lib,
  nix-update-script,
  pi-coding-agent,
}:
buildNpmPackage (finalAttrs: {
  pname = "pi-acp";
  version = "0.0.35";
  src = fetchFromGitHub {
    owner = "svkozak";
    repo = "pi-acp";
    rev = "v${finalAttrs.version}";
    hash = "sha256-/5ga4YEi5GZ95ru+9gDpXp9iWVqmLeInIHddskO4uXg=";
  };

  npmDepsHash = "sha256-BtLtlL0zpoOzN094Wf9GZrpfQm4eVpcITzMxfEeMpKI=";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "ACP adapter for pi coding agent";
    homepage = "https://github.com/svkozak/pi-acp";
    license = lib.licenses.mit;
    inherit (pi-coding-agent.meta) platforms;
    mainProgram = "pi-acp";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
