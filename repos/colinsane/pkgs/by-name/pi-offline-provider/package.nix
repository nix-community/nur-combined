{
  lib,
  llama-cpp-vulkan,
  mkPiExtension,
}:
mkPiExtension {
  pname = "pi-offline-provider";
  version = "0.1.0";

  # N.B.: update lockfiles with:
  # `$(nix-build -A nodejs)/bin/npm update`
  src = ./.;

  forceEmptyCache = true;
  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-57HhnO49cCMfOAgpjeEsutNJvWhFAuHgbvIlhlRPN3Q=";

  postPatch = ''
    substituteInPlace ./src/index.ts \
      --replace-fail '@llama_server@' ${lib.getExe' llama-cpp-vulkan "llama-server"}
    mkdir -p node_modules
  '';

  meta = {
    description = "Pi provider that starts a local llama.cpp server for offline LLM inference";
    maintainers = with lib.maintainers; [ colinsane ];
  };
}
