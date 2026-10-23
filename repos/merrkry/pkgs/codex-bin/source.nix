{ fetchurl }:

rec {
  version = "0.164.0";
  src = fetchurl {
    url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-package-x86_64-unknown-linux-musl.tar.zst";
    hash = "sha256-eAGuRzFjleOmOPthlkqfKPhKZkfBse2QMy5Na22gRtg=";
  };
}
