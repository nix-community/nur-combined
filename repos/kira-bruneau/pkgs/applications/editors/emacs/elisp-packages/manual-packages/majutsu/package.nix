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
    rev = "6208b260703f652883ca6376f2afeb7841994a86";
    hash = "sha256-ucwi2vXC3XpqILygjg5U00QTbPxedqpOYyPFLWOUQ+8=";
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
