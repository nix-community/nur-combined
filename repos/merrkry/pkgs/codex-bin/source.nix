{ fetchurl }:

rec {
  version = "0.168.0";
  src = fetchurl {
    url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-package-x86_64-unknown-linux-musl.tar.zst";
    hash = "sha256-sNwA6l39keCUQp6YMgoWivT6TCf77/ykTN7KUAIyZkk=";
  };
}
