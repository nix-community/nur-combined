{ mkDerivation }:

# How to obtain `sha256`:
# nix-prefetch-url --unpack https://github.com/elixir-lang/elixir/archive/v${version}.tar.gz
mkDerivation {
  version = "<<VERSION>>";
  sha256 = "<<SHA256>>";
  minimumOTPVersion = "21";
}
