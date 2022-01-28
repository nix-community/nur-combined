{ clang
, fetchFromGitHub
, lib
, llvmPackages
, protobuf
, rustPlatform
}:
rustPlatform.buildRustPackage rec {
  pname = "drml";
  version = "2.8.1";

  src = fetchFromGitHub {
    owner = "darwinia-network";
    repo = "darwinia-common";
    rev = "v${version}";
    sha256 = "sha256-TBrlPFQEA531RytoGbQicfvdfHW9p/llel6TzXaGHbs=";
  };

  cargoSha256 = "sha256-1qg4ZnSORRVI7eCVMrR7lY3tzo7KJt+dC2RBXqbKrig=";

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

  meta = with lib; {
    description = "Darwinia Runtime Pallet Library and Pangolin/Pangoro Testnet";
    homepage = "https://darwinia.network";
    license = licenses.gpl3Only;
    maintainers = [ "hujw77" ];
    platforms = platforms.linux;
  };
}
