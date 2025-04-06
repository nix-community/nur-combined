{
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  openssl,
  freetype,
}:

rustPlatform.buildRustPackage rec {
  pname = "tunet-rust";
  version = "0.9.5";

  src = fetchFromGitHub {
    owner = "Berrysoft";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-q4jJXSq7KCTSOD7unQT0IraXzf2zIx3/ZjO8Dq5dEK0=";
  };

  sourceRoot = src.name;

  cargoHash = "sha256-yL4+o1M64wHFrp6T3KWfdhb06V2WJqovA4gXB49vSEE=";

  cargoBuildFlags = [
    "--workspace"
    "--exclude"
    "native"
  ];

  doCheck = false;

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    openssl
    freetype
  ];

  meta = with lib; {
    description = "清华大学校园网 Rust 库与客户端";
    homepage = "https://github.com/Berrysoft/tunet-rust";
    license = licenses.mit;
    mainProgram = "degit-rs";
  };
}
