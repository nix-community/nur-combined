{ fetchurl }:

rec {
  version = "0.163.0";
  src = fetchurl {
    url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-package-x86_64-unknown-linux-musl.tar.zst";
    hash = "sha256-3yLawfJLeSfoF+ixEwZ/vhyqWGq6dVQkf6vUlGTPnJY=";
  };
}
