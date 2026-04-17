{
  lib,
  fetchFromGitHub,
  fetchNpmDeps,
  buildObsidianPlugin,
  npmHooks,
}:

buildObsidianPlugin (finalAttrs: {
  pname = "codeblock-customizer";
  version = "1.4.6";

  minObsidianVersion = "0.15.0";

  src = fetchFromGitHub {
    owner = "mugiwara85";
    repo = "CodeblockCustomizer";
    rev = "${finalAttrs.version}";
    hash = "sha256-EosaHIB9mfPB9CuzI6a9EkNIwSyQtVzCsUd/bqzNXF4=";
  };

  nativeBuildInputs = [
    npmHooks.npmConfigHook
    npmHooks.npmBuildHook
  ];

  npmDeps = fetchNpmDeps {
    name = "${finalAttrs.name}-npm-deps";
    inherit (finalAttrs) src;
    hash = "sha256-aeJD8X5ysdgiGfxA9qcxQuZth2VRmDp7swz9aWFLScU=";
  };

  meta = {
    description = "Customize Obsidian code blocks";
    license = lib.licenses.mit;
    homepage = "https://github.com/mugiwara85/CodeblockCustomizer/";
  };
})
