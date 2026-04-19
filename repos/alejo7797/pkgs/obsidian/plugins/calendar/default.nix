{
  lib,
  fetchFromGitHub,
  fetchYarnDeps,
  buildObsidianPlugin,
  yarnConfigHook,
  yarnBuildHook,
}:

buildObsidianPlugin (finalAttrs: {
  pname = "calendar";
  version = "2.0.0";

  manifest = lib.importJSON ./manifest.json;

  src = fetchFromGitHub {
    owner = "liamcain";
    repo = "obsidian-calendar-plugin";
    rev = "2.0.0-beta.2";
    hash = "sha256-KCZTgSxLLrRUVpM3t5qmxlsdrYifSQ0u3sq10y7Qf2s=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
  ];

  yarnOfflineCache = fetchYarnDeps {
    inherit (finalAttrs) src;
    hash = "sha256-ad+yZO5SvlRo1Xg9DJafmbsY54GJCk8jTDKBAF7QXuo=";
  };

  meta = {
    inherit (finalAttrs.manifest) description;
    license = lib.licenses.mit;
    homapage = "https://github.com/liamcain/obsidian-calendar-plugin/";
  };
})
