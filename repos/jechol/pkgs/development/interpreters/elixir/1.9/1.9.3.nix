{ mkDerivation }:

# How to obtain `sha256`:
# nix-prefetch-url --unpack https://github.com/elixir-lang/elixir/archive/v${version}.tar.gz
mkDerivation {
  version = "1.9.3";
  sha256 = "0h4jl1aihqi8lg08swllj0zw4liskf0daz615c7sbs63r48pp28h";
  minimumOTPVersion = "20";
}
