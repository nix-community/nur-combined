{ mkDerivation }:

# How to obtain `sha256`:
# nix-prefetch-url --unpack https://github.com/elixir-lang/elixir/archive/v${version}.tar.gz
mkDerivation {
  version = "1.8.2";
  sha256 = "1n77cpcl2b773gmj3m9s24akvj9gph9byqbmj2pvlsmby4aqwckq";
  minimumOTPVersion = "20";
}
