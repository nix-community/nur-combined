{ fetchurl }:

rec {
  version = "0.160.1";
  src = fetchurl {
    url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-package-x86_64-unknown-linux-musl.tar.zst";
    hash = "sha256-Bfknn8+3ZWShgB3YNShqVid8Ck3ZfZT1hUPnGy7V+Aw=";
  };
}
