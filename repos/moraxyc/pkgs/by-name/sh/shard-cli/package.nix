{
  rustPlatform,
  shard,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "${shard.pname}-cli";
  inherit (shard) src version cargoDeps;

  __structuredAttrs = true;
  strictDeps = true;

  cargoRoot = "./.";
  buildAndTestSubdir = "launcher";

  meta = shard.meta // {
    description = "CLI for the minimal, content-addressed Minecraft launcher";
    mainProgram = "shard";
  };
})
