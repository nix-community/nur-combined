{ mkDerivation }:

# How to obtain `sha256`:
# nix-prefetch-url --unpack https://github.com/elixir-lang/elixir/archive/v${version}.tar.gz
mkDerivation {
  version = "1.9.2";
  sha256 = "19yn6nx6r627f5zbyc7ckgr96d6b45sgwx95n2gp2imqwqvpj8wc";
  minimumOTPVersion = "20";
}
