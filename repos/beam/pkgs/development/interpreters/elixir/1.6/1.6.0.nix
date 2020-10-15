{ mkDerivation }:

# How to obtain `sha256`:
# nix-prefetch-url --unpack https://github.com/elixir-lang/elixir/archive/v${version}.tar.gz
mkDerivation {
  version = "1.6.0";
  sha256 = "0wfmbrq70n85mx17kl9h2k0xzgnhncz3xygjx9cbvpmiwwdzgrdx";
  minimumOTPVersion = "19";
}
