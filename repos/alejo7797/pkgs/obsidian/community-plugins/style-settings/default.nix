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

  manifest = lib.importJSON ./manifest.json;

  src = fetchFromGitHub {
    owner = "obsidian-community";
    repo = "obsidian-style-settings";
    rev = "${finalAttrs.version}";
    hash = "sha256-eNbZQ/u3mufwVX+NRJpMSk5uGVkWfW0koXKq7wg9d+I=";
  };

  patches = [
    ./fix-pickr-url.patch
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
    inherit (finalAttrs.manifest) description;
    license = lib.licenses.gpl3;
    homapage = "https://github.com/mgmeyers/obsidian-style-settings";
  };
})
