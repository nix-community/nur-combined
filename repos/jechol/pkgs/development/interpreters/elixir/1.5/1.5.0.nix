{ mkDerivation }:

# How to obtain `sha256`:
# nix-prefetch-url --unpack https://github.com/elixir-lang/elixir/archive/v${version}.tar.gz
mkDerivation {
  version = "1.5.0";
  sha256 = "1y8c0s0wfgv444vhpnz9v8z8rc39kqhzzzkzqjxsh576vd868pbz";
  minimumOTPVersion = "18";
}
