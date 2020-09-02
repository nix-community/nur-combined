{ mkDerivation }:

# How to obtain `sha256`:
# nix-prefetch-url --unpack https://github.com/elixir-lang/elixir/archive/v${version}.tar.gz
mkDerivation {
  version = "1.7.0";
  sha256 = "082924fngc6ypbkn1ghdwf199radk00daf4q09mm04h81jy4nmxm";
  minimumOTPVersion = "19";
}
