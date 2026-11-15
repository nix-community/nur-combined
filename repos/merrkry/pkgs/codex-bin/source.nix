{ fetchurl }:

rec {
  version = "0.169.0";
  src = fetchurl {
    url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-package-x86_64-unknown-linux-musl.tar.zst";
    hash = "sha256-bQK6/wUoGOjCrOPiLBvZ7DcjUkaG5Yb8E0LkyqBGiac=";
  };
}
