{ fetchurl }:

rec {
  version = "0.165.0";
  src = fetchurl {
    url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-package-x86_64-unknown-linux-musl.tar.zst";
    hash = "sha256-/wXBX9Y6BzSwtCMbxN3fDFmvBtynnApefFX5do2xqSw=";
  };
}
