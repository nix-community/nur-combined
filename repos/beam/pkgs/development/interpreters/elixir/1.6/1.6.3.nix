{ mkDerivation }:

# How to obtain `sha256`:
# nix-prefetch-url --unpack https://github.com/elixir-lang/elixir/archive/v${version}.tar.gz
mkDerivation {
  version = "1.6.3";
  sha256 = "10ywd7ksvlg4lb7r6qizxyf906rafn6iwxnl945gv1gl4c6h4xfx";
  minimumOTPVersion = "19";
}
