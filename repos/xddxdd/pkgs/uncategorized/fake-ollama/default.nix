{
  buildGoModule,
  lib,
  sources,
}:
buildGoModule {
  inherit (sources.fake-ollama) pname version src;
  vendorHash = "sha256-Ef2XLxGq8TO3WVh9EvLE30Is2CBwH4pqXxkq1tcuR0Q=";

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Simulated server implementation of Ollama API";
    homepage = "https://github.com/spoonnotfound/fake-ollama";
    license = lib.licenses.mit;
    mainProgram = "fake-ollama";
  };
}
