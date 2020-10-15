{ mkDerivation }:

# How to obtain `sha256`:
# nix-prefetch-url --unpack https://github.com/elixir-lang/elixir/archive/v${version}.tar.gz
mkDerivation {
  version = "1.5.2";
  sha256 = "0ng7z2gz1c8lkn07fric18b3awcw886s9xb864kmnn2iah5gc65j";
  minimumOTPVersion = "18";
}
