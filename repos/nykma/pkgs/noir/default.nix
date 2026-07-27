{
  version ? "1.0.0-beta.7",
  hash ? "sha256-7MZ2hh8yRQlJ7/cKGF4CEg25s4CFXnOVv4IRQBlCNEU=",
  cargoHash ? "sha256-QupLrl8U7vdp1Q/9IirW20T4tha+T1/XXCWZGyzeMCo=",
  lib, fetchFromGitHub, makeRustPlatform, rust-bin,
  protobuf_29, # 29.3
}:
let
  pname = "noir";
  rustPlatform = makeRustPlatform {
    cargo = rust-bin.stable.latest.default;
    rustc = rust-bin.stable.latest.default;
  };
in
rustPlatform.buildRustPackage {
  inherit pname version cargoHash;

  src = fetchFromGitHub {
    inherit hash;
    owner = "noir-lang";
    repo = pname;
    rev = "v${version}";
  };

  nativeBuildInputs = [ ];
  buildInputs = [ ];

  PROTOC_PREBUILT_FORCE_PROTOC_PATH = "${protobuf_29}/bin/protoc";
  PROTOC_PREBUILT_FORCE_INCLUDE_PATH = "${protobuf_29}/include";
  GIT_COMMIT = version;
  GIT_DIRTY = "false";

  doCheck = false;

  meta = with lib; {
    description = "Noir is a domain specific language for zero knowledge proofs.";
    homepage = "https://noir-lang.org";
    license = licenses.asl20;
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
      # FIXME: enable until proper cargoHash for each platform is found
      # "aarch64-linux"
      # "x86_64-darwin"
    ];
  };
}
