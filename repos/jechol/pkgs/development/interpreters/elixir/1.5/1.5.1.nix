{ mkDerivation }:

# How to obtain `sha256`:
# nix-prefetch-url --unpack https://github.com/elixir-lang/elixir/archive/v${version}.tar.gz
mkDerivation {
  version = "1.5.1";
  sha256 = "0q0zr3v9cyb7p9aab8v038hnjm84nf9b60kikffp6w9rfqqqf767";
  minimumOTPVersion = "18";
}
