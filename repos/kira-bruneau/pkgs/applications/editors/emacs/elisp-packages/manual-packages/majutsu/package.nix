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
  version = "0.3.0-unstable-2025-12-07";

  src = fetchFromGitHub {
    owner = "0WD0";
    repo = "majutsu";
    rev = "e7385c6a581ad04ada96b9b5a87998cd3a311d2c";
    hash = "sha256-vnGtINWHmEh/yVPsxMHjoehHILgeAdl3heYAJPk2TE0=";
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
