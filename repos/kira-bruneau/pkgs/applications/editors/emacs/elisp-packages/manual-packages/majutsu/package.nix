{
  lib,
  melpaBuild,
  fetchFromGitHub,
  magit,
  evil,
  nix-update-script,
}:

melpaBuild (finalAttrs: {
  pname = "majutsu";
  version = "0.4.0-unstable-2025-12-24";

  src = fetchFromGitHub {
    owner = "0WD0";
    repo = "majutsu";
    rev = "2008d6cc219875dee2f95da96c6912debff2f039";
    hash = "sha256-EabVcT+4bpwWY04AEpp6QBXz+54sSfjDCzF7u/wFkto=";
  };

  packageRequires = [
    magit
    evil
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Magit for jujutsu";
    homepage = "https://github.com/0WD0/majutsu";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kira-bruneau ];
  };
})
