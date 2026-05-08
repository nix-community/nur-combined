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
  version = "0.6.0-unstable-2026-05-01";

  src = fetchFromGitHub {
    owner = "0WD0";
    repo = "majutsu";
    rev = "f63c90a67cd4f4c3428f2b7ba2c284b057a5b832";
    hash = "sha256-hxP1X+vXqdwPo0XQ2cmZqYsZNxmpXWXcyAIt5zCN8Wg=";
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
