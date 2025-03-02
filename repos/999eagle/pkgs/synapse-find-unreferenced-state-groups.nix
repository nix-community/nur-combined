{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "synapse-find-unreferenced-state-groups";
  version = "unstable-2022-09-02";

  src = fetchFromGitHub {
    owner = "erikjohnston";
    repo = pname;
    rev = "e873f9a721e9a3a297ddf4299396cbf11d972b4d";
    hash = "sha256-o12mo5oyNFEuZuClH9ovKjo3C42n5wsj7hdb4R4pQUY=";
  };
  useFetchCargoVendor = true;
  cargoHash = "sha256-zEbbON2UYOESksMRK+blhNLwdciYl5fPr8cP1UBf39w=";

  meta = {
    mainProgram = "rust-synapse-find-unreferenced-state-groups";
    description = "Finds unreferenced state groups persisted by synapse";
    homepage = "https://github.com/erikjohnston/synapse-find-unreferenced-state-groups";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [_999eagle];
  };
}
