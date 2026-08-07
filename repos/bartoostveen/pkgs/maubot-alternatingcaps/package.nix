{
  lib,
  maubot,
  fetchFromGitHub,
  nix-update-script,
}:

maubot.plugins.buildMaubotPlugin rec {
  pname = "pl.rom4nik.maubot.alternatingcaps";
  version = "0.1.3";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "rom4nik";
    repo = "maubot-alternatingcaps";
    tag = "v${version}";
    hash = "sha256-RUwZ6SOsWiygyb10GnDmvskAurSiW9rFwDylYgr6wII=";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "ALtErNaTiNg cApS, now on Matrix";
    homepage = "https://github.com/rom4nik/maubot-alternatingcaps";
    changelog = "https://github.com/rom4nik/maubot-alternatingcaps/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bartoostveen ];
  };
}
