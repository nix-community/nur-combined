{
  buildGoModule,
  fetchFromGitHub,
  lib,
  unstableGitUpdater,
}:
buildGoModule (finalAttrs: {
  pname = "fake-ollama";
  version = "0-unstable-2025-02-14";
  src = fetchFromGitHub {
    owner = "spoonnotfound";
    repo = "fake-ollama";
    rev = "4a788616cee7d0f3b39f7623d9f627b79acae405";
    hash = "sha256-ChktqmEoZ2PN13XqynExyjYbX2uhbeAfubNKhTZ4cUY=";
  };
  vendorHash = "sha256-Ef2XLxGq8TO3WVh9EvLE30Is2CBwH4pqXxkq1tcuR0Q=";

  passthru.updateScript = unstableGitUpdater {
    url = "https://github.com/spoonnotfound/fake-ollama";
    hardcodeZeroVersion = true;
  };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Simulated server implementation of Ollama API";
    homepage = "https://github.com/spoonnotfound/fake-ollama";
    license = lib.licenses.mit;
    mainProgram = "fake-ollama";
  };
})
