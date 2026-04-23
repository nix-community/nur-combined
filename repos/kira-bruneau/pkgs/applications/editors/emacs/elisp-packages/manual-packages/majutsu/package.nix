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
  version = "0.6.0-unstable-2026-04-22";

  src = fetchFromGitHub {
    owner = "0WD0";
    repo = "majutsu";
    rev = "bb9cd25cb97e5b8948d0e91f8746a81acc8ed1d1";
    hash = "sha256-4H2P9NnQne5P14+VrH27VIw4I2340o+8F6AiCofY8i4=";
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
