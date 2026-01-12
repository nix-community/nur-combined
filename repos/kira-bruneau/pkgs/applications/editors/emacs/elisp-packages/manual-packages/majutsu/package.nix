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
  version = "0.4.0-unstable-2025-12-30";

  src = fetchFromGitHub {
    owner = "0WD0";
    repo = "majutsu";
    rev = "891f95a49d892f633d0e62939e63927940071714";
    hash = "sha256-Bk9O6ujhSELNIXoYqqSjuy9lOPwLY1SzVN14uaB9eYA=";
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
