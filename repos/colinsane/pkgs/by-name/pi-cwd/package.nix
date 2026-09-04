{
  fetchFromGitHub,
  lib,
  mkPiExtension,
  nix-update-script,
}:
mkPiExtension (finalAttrs: {
  pname = "pi-cwd";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "harms-haus";
    repo = "pi-cwd";
    rev = "7af506e696d214f0ee7087e817d2ee142b28a6b7";
    hash = "sha256-P7t6E6qdRJyf+gBEMKAT/cI0rlX7CJqNSrclUT92JN4=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-zYZWyeX/B0+UfHnnp/AXv9cFw9lJJOMH4tQVHAKmC2o=";

  dontNpmBuild = true;  # package.json defines no build script

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Change working directory inside the agent tui";
    homepage = "https://github.com/harms-haus/pi-cwd";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
