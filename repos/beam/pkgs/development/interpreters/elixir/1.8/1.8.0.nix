{ mkDerivation }:

# How to obtain `sha256`:
# nix-prefetch-url --unpack https://github.com/elixir-lang/elixir/archive/v${version}.tar.gz
mkDerivation {
  version = "1.8.0";
  sha256 = "156md90qzg0ghj5vck09hzhjks0m8jahcbgrrrgk7i7qcmad8x2k";
  minimumOTPVersion = "20";
}
