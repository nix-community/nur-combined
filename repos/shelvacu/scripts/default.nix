_: {
  archive = ./archive/package.nix;
  get-crypto-rates = ./get-crypto-rates/package.nix;
}
# eventually, when I clean up the rest:
# { vaculib, ... }:
# vaculib.directoryGrabber {
#   path = ./.;
#   mainName = "package.nix";
# }
