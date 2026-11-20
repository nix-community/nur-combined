{ fetchurl }:

rec {
  version = "0.171.0";
  src = fetchurl {
    url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-package-x86_64-unknown-linux-musl.tar.zst";
    hash = "sha256-hn4PY4oDu7+SLh93q9cNIuKD4qU/kygfygCayNDe5OA=";
  };
}
