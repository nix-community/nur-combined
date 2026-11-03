{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "wakaru";
  version = "1.16.0";

  src = fetchFromGitHub {
    owner = "pionxzh";
    repo = "wakaru";
    rev = "v${version}";
    hash = "sha256-lo/EJC8BeU+C3KB5M1/3L68a4iUbW6w05ImsZHllsZo=";
  };

  cargoHash = "sha256-j75BEvh1ig5kndB9Kd21m9OFaNokmB/LI1QQitL5z/E=";
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
