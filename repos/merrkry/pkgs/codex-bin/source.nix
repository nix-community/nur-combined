{ fetchurl }:

rec {
  version = "0.166.0";
  src = fetchurl {
    url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-package-x86_64-unknown-linux-musl.tar.zst";
    hash = "sha256-j3rtxOL4U1dc4VQ0lq/Ir1Fmb3Yo+1NYEO2fagE98b4=";
  };
}
