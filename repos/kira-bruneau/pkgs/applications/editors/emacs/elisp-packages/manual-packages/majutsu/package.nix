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
  version = "0.3.0-unstable-2025-12-16";

  src = fetchFromGitHub {
    owner = "0WD0";
    repo = "majutsu";
    rev = "f0c1a28c22e729af5f396d361113bd3a3a874079";
    hash = "sha256-QkIvnH5CyWrsLukfdWekURmoQcIEAHYTEDxHFiuA1Ak=";
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
