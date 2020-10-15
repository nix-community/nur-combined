{ mkDerivation }:

# How to obtain `sha256`:
# nix-prefetch-url --unpack https://github.com/elixir-lang/elixir/archive/v${version}.tar.gz
mkDerivation {
  version = "1.6.5";
  sha256 = "0il1fraz6c8qbqv4wrp16jqrkf3xglfa9f3sdm6q4vv8kjf3lxxb";
  minimumOTPVersion = "19";
}
