{
  lib,
  fetchFromGitHub,
  fetchNpmDeps,
  buildObsidianPlugin,
  npmHooks,
}:

buildObsidianPlugin (finalAttrs: {
  pname = "vimrc-support";
  version = "0.10.2";

  manifest = lib.importJSON ./manifest.json;

  src = fetchFromGitHub {
    owner = "esm7";
    repo = "obsidian-vimrc-support";
    rev = "1ff5d97afcf3161f202aa460697233d550f6aa3f";
    hash = "sha256-1A2dVgyPg6MUmOBJrFijKbTXUgtPOAnazQg1i6gczvI=";
  };

  nativeBuildInputs = [
    npmHooks.npmConfigHook
    npmHooks.npmBuildHook
  ];

  npmDeps = fetchNpmDeps {
    name = "${finalAttrs.name}-npm-deps";
    inherit (finalAttrs) src;
    hash = "sha256-i9GcaYtLtJiS6t+rQK6LaC1k1U8LjwANNMqAVv4stw8=";
  };

  meta = {
    inherit (finalAttrs.manifest) description;
    license = lib.licenses.mit;
    homepage = "https://github.com/esm7/obsidian-vimrc-support";
  };
})
