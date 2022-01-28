{ clang
, fetchFromGitHub
, lib
, llvmPackages
, protobuf
, rustPlatform
}:
rustPlatform.buildRustPackage rec {
  pname = "drml";
  version = "debug-bsc";

  src = fetchFromGitHub {
    owner = "darwinia-network";
    repo = "darwinia-common";
    rev = "debug-bsc";
    sha256 = "sha256-ONTxgVz1l/kJsp1hW+xw8CbvXbIznejWvmoIHiqZX8Q=";
  };

  cargoPatches = [ ./cargo-lock.patch ];

  cargoSha256 = "sha256-/JQDUtSSkuO9nrYVSkQOaZjps1BUuH8Bc1SMyDSSJS4=";

  nativeBuildInputs = [ clang ];

  LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";
  PROTOC = "${protobuf}/bin/protoc";

  # NOTE: We don't build the WASM runtimes since this would require a more
  # complicated rust environment setup and this is only needed for developer
  # environments. The resulting binary is useful for end-users of live networks
  # since those just use the WASM blob from the network chainspec.
  SKIP_WASM_BUILD = 1;

  # We can't run the test suite since we didn't compile the WASM runtimes.
  doCheck = false;

  cargoBuildFlags = [ "--profile" "release-lto" "--bin" "drml" ];

  meta = with lib; {
    description = "Darwinia Runtime Pallet Library and Pangolin/Pangoro Testnet";
    homepage = "https://darwinia.network";
    license = licenses.gpl3Only;
    maintainers = [ "hujw77" ];
    platforms = platforms.linux;
  };
}
