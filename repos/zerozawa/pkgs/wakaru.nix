{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "wakaru";
  version = "1.14.0";

  src = fetchFromGitHub {
    owner = "pionxzh";
    repo = "wakaru";
    rev = "v${version}";
    hash = "sha256-HdSrirk4VcWlifK4m97fJbyfXeIhLfzWRWQGPxAd0hI=";
  };

  cargoHash = "sha256-t3LS3nMihmHmRmJ014YkvXYynv4XwtQWn267GAWnLiE=";
  # Only the CLI; crates/wasm is a wasm32 cdylib we have no use for.
  cargoBuildFlags = [
    "-p"
    "wakaru-cli"
  ];
  doCheck = false;

  meta = with lib; {
    description = "Unpack. Unminify. Understand.";
    homepage = "https://github.com/pionxzh/wakaru";
    license = licenses.asl20;
    mainProgram = "wakaru";
    platforms = platforms.unix;
  };
}
