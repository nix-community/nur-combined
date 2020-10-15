{ mkDerivation }:

# How to obtain `sha256`:
# nix-prefetch-url --unpack https://github.com/elixir-lang/elixir/archive/v${version}.tar.gz
mkDerivation {
  version = "1.9.0";
  sha256 = "0yfqh07wjgm10v6acn5pw8l8jndjly5kpzgw4harlj81wcaymlsw";
  minimumOTPVersion = "20";
}
