{ mkDerivation }:

# How to obtain `sha256`:
# nix-prefetch-url --unpack https://github.com/elixir-lang/elixir/archive/v${version}.tar.gz
mkDerivation {
  version = "1.9.1";
  sha256 = "106s2a3dykc5iwfrd5icqd737yfzaz1dw4x5v1j5z2fvf46h96dx";
  minimumOTPVersion = "20";
}
