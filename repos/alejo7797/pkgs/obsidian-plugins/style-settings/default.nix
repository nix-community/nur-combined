{
  lib,
  fetchFromGitHub,
  fetchYarnDeps,
  buildObsidianPlugin,
  yarnConfigHook,
  yarnBuildHook,
}:

buildObsidianPlugin (finalAttrs: {
  pname = "style-settings";
  version = "1.0.9";

  minObsidianVersion = "0.11.5";

  src = fetchFromGitHub {
    owner = "obsidian-community";
    repo = "obsidian-style-settings";
    rev = "${finalAttrs.version}";
    hash = "sha256-eNbZQ/u3mufwVX+NRJpMSk5uGVkWfW0koXKq7wg9d+I=";
  };

  patches = [
    ./tweak-pickr-url.patch
  ];

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
  ];

  yarnOfflineCache = fetchYarnDeps {
    inherit (finalAttrs) src patches;
    hash = "sha256-2uM+OWRiOhxDWG4Vp/zoU3yAoyCNsFOH4Udx1Tr+25w=";
  };

  meta = {
    description = "Dynamic user interface for adjusting theme, plugin, and snippet CSS variables within Obsidian";
    license = lib.licenses.gpl3;
    homepage = "https://github.com/obsidian-community/obsidian-style-settings/";
  };
})
