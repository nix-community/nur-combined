{ fetchurl }:

rec {
  version = "0.167.0";
  src = fetchurl {
    url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-package-x86_64-unknown-linux-musl.tar.zst";
    hash = "sha256-n2e4hoixQ1kH4hSIWI/yAR/f8n5YLS05XohVv1Z6jP8=";
  };
}
