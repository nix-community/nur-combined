{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "rustfilt";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "luser";
    repo = "rustfilt";
    rev = version;
    hash = "sha256-zb1tkeWmeMq7aM8hWssS/UpvGzGbfsaVYCOKBnAKwiQ=";
  };

  cargoHash = "sha256-rs2EWcvTxLVeJ0t+jLM75s+K72t+hqKzwy3oAdCZ8BE=";

  meta = {
    description = "Demangle Rust symbols";
    homepage = "https://github.com/luser/rustfilt";
    license = with lib.licenses; [ asl20 ];
  };
}
