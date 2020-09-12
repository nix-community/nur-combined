{ mkDerivation }:

# How to obtain `sha256`:
# nix-prefetch-url --unpack https://github.com/elixir-lang/elixir/archive/v${version}.tar.gz
mkDerivation {
  version = "1.7.3";
  sha256 = "0d7rj4khmvy76z12njzwzknm1j9rhjadgj9k1chjd4gnjffkb1aa";
  minimumOTPVersion = "19";
}
