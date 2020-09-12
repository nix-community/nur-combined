{ mkDerivation }:

# How to obtain `sha256`:
# nix-prefetch-url --unpack https://github.com/elixir-lang/elixir/archive/v${version}.tar.gz
mkDerivation {
  version = "1.8.1";
  sha256 = "1npnrkn21kqqfqrsn06mr78jxs6n5l8c935jpxvnmj7iysp50pf9";
  minimumOTPVersion = "20";
}
