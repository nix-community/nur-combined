{
  lib,
  fetchFromGitHub,
  fetchNpmDeps,
  buildObsidianTheme,
  npmHooks,
  grunt-cli,
}:

buildObsidianTheme (finalAttrs: {
  pname = "minimal";
  version = "8.1.7";

  manifest = lib.importJSON ./manifest.json;

  src = fetchFromGitHub {
    owner = "kepano";
    repo = "obsidian-minimal";
    rev = "${finalAttrs.version}";
    hash = "sha256-rpqFtbHV1xceioeykivi/2b93QrkZzTl4H+jaX35ERY=";
  };

  nativeBuildInputs = [
    grunt-cli
    npmHooks.npmConfigHook
  ];

  npmDeps = fetchNpmDeps {
    name = "${finalAttrs.name}-npm-deps";
    inherit (finalAttrs) src;
    hash = "sha256-QY2vaV/Eq46KvdOmoPRu7izKmOm/0CnRbFnLhHMZX7A=";
  };

  buildPhase = ''
    runHook preBuild

    npx grunt sass cssmin concat_css

    runHook postBuild
  '';

  meta = {
    description = "Distraction-free and highly customizable theme for Obsidian";
    license = lib.licenses.mit;
    homepage = "https://minimal.guide/";
  };
})
