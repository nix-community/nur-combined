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
  version = "0.4.0-unstable-2025-12-18";

  src = fetchFromGitHub {
    owner = "0WD0";
    repo = "majutsu";
    rev = "5804210752aee59da80b5b165fcb1330aea6fb40";
    hash = "sha256-tmRP91i1A/+FgQ//Uzt5dpaCK13xGolK8D0eEyD9UhU=";
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
