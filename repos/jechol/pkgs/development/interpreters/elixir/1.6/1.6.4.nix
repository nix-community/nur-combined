{ mkDerivation }:

# How to obtain `sha256`:
# nix-prefetch-url --unpack https://github.com/elixir-lang/elixir/archive/v${version}.tar.gz
mkDerivation {
  version = "1.6.4";
  sha256 = "0li2zb5ha7fdkjnzjbj3dxb9xls8xn6xr23fqwl7gp2697vcw3ws";
  minimumOTPVersion = "19";
}
