{ fetchurl }:

rec {
  version = "0.162.1";
  src = fetchurl {
    url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-package-x86_64-unknown-linux-musl.tar.zst";
    hash = "sha256-vSTQK+Z4iUtHvFZb0tqNR6BeOn3Qtu9mqpVymbJOyPI=";
  };
}
