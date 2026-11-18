{ fetchurl }:

rec {
  version = "0.170.0";
  src = fetchurl {
    url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-package-x86_64-unknown-linux-musl.tar.zst";
    hash = "sha256-4vmhSMhiMzhADSguIzp6ggJLS/c4A8QAw/r3qEFd3Ks=";
  };
}
