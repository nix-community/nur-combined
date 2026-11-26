{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
}:

buildNpmPackage (finalAttrs: {
  pname = "pi-acp";
  version = "0.0.35";

  src = fetchFromGitHub {
    owner = "svkozak";
    repo = "pi-acp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/5ga4YEi5GZ95ru+9gDpXp9iWVqmLeInIHddskO4uXg=";
  };

  npmDepsHash = "sha256-BtLtlL0zpoOzN094Wf9GZrpfQm4eVpcITzMxfEeMpKI=";

  meta = {
    description = "ACP (Agent Client Protocol) adapter for the pi coding agent";
    homepage = "https://github.com/svkozak/pi-acp";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "pi-acp";
  };
})
