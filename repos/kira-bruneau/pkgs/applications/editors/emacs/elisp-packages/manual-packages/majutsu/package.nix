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
  version = "0.4.0-unstable-2025-12-28";

  src = fetchFromGitHub {
    owner = "0WD0";
    repo = "majutsu";
    rev = "7d32ecac0db07afd1abe242ca92b77a66d466876";
    hash = "sha256-Ph2GtMZIxUAzSK8Tvlkp8th4Y5MzEPgI5lisDWlvqew=";
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
