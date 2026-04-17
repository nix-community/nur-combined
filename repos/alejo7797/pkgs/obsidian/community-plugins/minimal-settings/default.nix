{
  lib,
  fetchFromGitHub,
  fetchNpmDeps,
  buildObsidianPlugin,
  npmHooks,
}:

buildObsidianPlugin (finalAttrs: {
  pname = "minimal-settings";
  version = "8.1.1";

  manifest = lib.importJSON ./manifest.json;

  src = fetchFromGitHub {
    owner = "kepano";
    repo = "obsidian-minimal-settings";
    rev = "${finalAttrs.version}";
    hash = "sha256-JcWqSVgSRJAm0QiLnGuPpv0S9SVZw7UdtuKnvUAKiwQ=";
  };

  patches = [
    ./fix-package-lock.patch
  ];

  nativeBuildInputs = [
    npmHooks.npmConfigHook
    npmHooks.npmBuildHook
  ];

  npmDeps = fetchNpmDeps {
    name = "${finalAttrs.name}-npm-deps";
    inherit (finalAttrs) src patches;
    hash = "sha256-0biybS5nMquAqgKOukW5y1CTOkYbvQZre87Nco7U+gQ=";
  };

  meta = {
    inherit (finalAttrs.manifest) description;
    license = lib.licenses.mit;
    homepage = "https://minimal.guide/";
  };
})
