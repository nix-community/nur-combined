{ mkDerivation }:

# How to obtain `sha256`:
# nix-prefetch-url --unpack https://github.com/elixir-lang/elixir/archive/v${version}.tar.gz
mkDerivation {
  version = "1.6.6";
  sha256 = "1wl8rfpw0dxacq4f7xf6wjr8v2ww5691d0cfw9pzw7phd19vazgl";
  minimumOTPVersion = "19";
}
