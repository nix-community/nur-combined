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
  version = "0.5.0-unstable-2026-01-12";

  src = fetchFromGitHub {
    owner = "0WD0";
    repo = "majutsu";
    rev = "94220b86936f0f525a5a5f03a683f9c5a57d45bf";
    hash = "sha256-Yx/+k/kvHVgMI3mHQWvb+LbK8XTBiKHGgn/d2k2ar1c=";
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
