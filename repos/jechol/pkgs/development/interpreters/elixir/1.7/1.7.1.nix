{ mkDerivation }:

# How to obtain `sha256`:
# nix-prefetch-url --unpack https://github.com/elixir-lang/elixir/archive/v${version}.tar.gz
mkDerivation {
  version = "1.7.1";
  sha256 = "0y9wkwkr9pbkrfm9z4sjv8a2cqvgjb7qbsqpyal0kz232npy0pxs";
  minimumOTPVersion = "19";
}
