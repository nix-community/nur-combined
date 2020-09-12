{ mkDerivation }:

# How to obtain `sha256`:
# nix-prefetch-url --unpack https://github.com/elixir-lang/elixir/archive/v${version}.tar.gz
mkDerivation {
  version = "1.7.2";
  sha256 = "0wnrx6wlpmr23ypm8za0c4dl952nj4rjylcsdzz0xrma92ylrqfq";
  minimumOTPVersion = "19";
}
