{ mkDerivation }:

# How to obtain `sha256`:
# nix-prefetch-url --unpack https://github.com/elixir-lang/elixir/archive/v${version}.tar.gz
mkDerivation {
  version = "1.7.4";
  sha256 = "0f8j4pib13kffiihagdwl3xqs3a1ak19qz3z8fpyfxn9dnjiinla";
  minimumOTPVersion = "19";
}
