{ fetchurl }:

rec {
  version = "0.162.0";
  src = fetchurl {
    url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-package-x86_64-unknown-linux-musl.tar.zst";
    hash = "sha256-7XZTScUAdWOX9TY7xwz9k3JfQoAmTh8EOEZB3wPrgk8=";
  };
}
