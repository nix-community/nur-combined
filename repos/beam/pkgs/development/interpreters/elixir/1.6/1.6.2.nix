{ mkDerivation }:

# How to obtain `sha256`:
# nix-prefetch-url --unpack https://github.com/elixir-lang/elixir/archive/v${version}.tar.gz
mkDerivation {
  version = "1.6.2";
  sha256 = "18f5afmvra78y0x73bfnwbddlyqfndyaj1h8n1ybj32w4nvy96y7";
  minimumOTPVersion = "19";
}
