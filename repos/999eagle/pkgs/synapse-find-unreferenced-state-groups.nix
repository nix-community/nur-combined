{
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
  cargoSha256 = "sha256-q9mkDITPT275g67+iJoFnDXoPfzz2Qm1Pz9MAnb4i2o=";

  # nativeBuildInputs = [pkg-config];
  # buildInputs = [openssl];
}
