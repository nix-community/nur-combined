{
  lib,
  rustPlatform,
  fetchCrate,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "mcpeek";
  version = "1.0.0";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-SpolvmMfli5yHmnDpNj/8JGjAVyHfeJ2RGCh7wC+eLU=";
  };

  cargoHash = "sha256-wZ9d2DtzpUigNcPPlAlp1c4mq0U51dY8wciIX6vUT44=";

  meta = {
    description = "TUI MCP inspector";
    homepage = "https://github.com/subpop/mcpeek";
    changelog = "https://github.com/subpop/mcpeek/releases";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "mcpeek";
  };
})
