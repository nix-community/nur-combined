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
  version = "0.6.0-unstable-2026-04-23";

  src = fetchFromGitHub {
    owner = "0WD0";
    repo = "majutsu";
    rev = "d46dc2019375b5be08c5cb222d9345402b4e8b8e";
    hash = "sha256-Co1m0/sa3/Gg9QxnQR+dvQ9FrbuGCSV3Rz9Uc86TU9Q=";
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
