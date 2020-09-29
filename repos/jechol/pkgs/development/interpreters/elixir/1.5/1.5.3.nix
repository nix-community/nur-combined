{ mkDerivation }:

# How to obtain `sha256`:
# nix-prefetch-url --unpack https://github.com/elixir-lang/elixir/archive/v${version}.tar.gz
mkDerivation {
  version = "1.5.3";
  sha256 = "00kgqcn9g6vflc551wniz9pwv7pszyf8v6smpkqs50j3kbliihy5";
  minimumOTPVersion = "18";
}
