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
  version = "0.6.0-unstable-2026-02-17";

  src = fetchFromGitHub {
    owner = "0WD0";
    repo = "majutsu";
    rev = "fc431ac3c50cd8f6f7d6c24ac6302994f7b49f00";
    hash = "sha256-DtO+fZFpNo9xTMvMx4FDQ253LgAncJN6YmQ0PQZzdG0=";
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
