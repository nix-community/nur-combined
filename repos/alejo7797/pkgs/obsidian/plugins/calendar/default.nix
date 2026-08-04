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
  version = "1.5.10";

  manifest = lib.importJSON ./manifest.json;

  src = fetchFromGitHub {
    owner = "liamcain";
    repo = "obsidian-calendar-plugin";
    rev = "${finalAttrs.version}";
    hash = "sha256-SQtr2ZI5MecyNYS40okR+uEirww4GZz9WmQObv7ffNc=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
  ];

  yarnOfflineCache = fetchYarnDeps {
    inherit (finalAttrs) src;
    hash = "sha256-YvJbiMU+1tQ6V9MCiICCxaShvDfCNtXy0AqOt73vCz0=";
  };

  meta = {
    inherit (finalAttrs.manifest) description;
    license = lib.licenses.mit;
    homapage = "https://github.com/liamcain/obsidian-calendar-plugin/";
  };
})
