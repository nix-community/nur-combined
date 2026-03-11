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
  version = "0.6.0-unstable-2026-03-04";

  src = fetchFromGitHub {
    owner = "0WD0";
    repo = "majutsu";
    rev = "bb56ca9223df4a54582852b79421d9cccfc0d78e";
    hash = "sha256-GJ1HuacEvir269dE+9V4J/r4mLasQ3eB9yokqx0UJEI=";
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
