{ mkDerivation }:

# How to obtain `sha256`:
# nix-prefetch-url --unpack https://github.com/elixir-lang/elixir/archive/v${version}.tar.gz
mkDerivation {
  version = "1.6.1";
  sha256 = "01q5nxpgbpkiw9wk7na6arxc5s75sc3qh8gw8xwnrgxg9iabkqcf";
  minimumOTPVersion = "19";
}
