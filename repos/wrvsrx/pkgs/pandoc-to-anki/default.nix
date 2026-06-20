{
  rustPlatform,
  protobuf,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "pandoc-to-anki";
  version = "0.3.0";
  src = fetchFromGitHub {
    owner = "wrvsrx";
    repo = "pandoc-to-anki";
    tag = finalAttrs.version;
    fetchSubmodules = true;
    hash = "sha256-38RMtdeZpjsSZQpyAIL9E2nHSJfszik6RrBfM+Qrlv4=";
  };
  nativeBuildInputs = [ protobuf ];
  cargoHash = "sha256-K3t4N5hnZ9rBAEfaqdR5n3MlPYcra34tZn0Yiu8uSVs=";
})
