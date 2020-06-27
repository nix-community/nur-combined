# NOTE: Project abandoned
# FIXME: Tries to load resources from /null/nix/store?
# FIXME: Randomly freezes

{ fetchFromGitHub }:

fetchFromGitHub {
  owner = "artur9010";
  repo = "lightdm-webkit-material";
  rev = "6ed8a08e7f3edb2c28928b74eafdde8c13618e61";
  sha256 = "1jpvz6197ysimrv5qr2k87iv65x7c3kg95a646w3mx2g00blk779";
}
