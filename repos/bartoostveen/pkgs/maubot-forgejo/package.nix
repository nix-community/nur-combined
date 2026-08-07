{
  lib,
  maubot,
  fetchFromCodeberg,
  nix-update-script,
}:

maubot.plugins.buildMaubotPlugin rec {
  pname = "vibb.me.forgebot";
  version = "0.1.7";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromCodeberg {
    owner = "palchrb";
    repo = "maubot_forgejo";
    tag = "v${version}";
    hash = "sha256-IP985g6cPR3YRyrIaDikj3VAodIZjuYCYrJPiZGEDVw=";
    fetchSubmodules = true;
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Forgejo/Codeberg webhook/client plugin for maubot, heavily inspired by Tulir's maubot github plugin";
    homepage = "https://codeberg.org/palchrb/maubot_forgejo";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ bartoostveen ];
  };
}
