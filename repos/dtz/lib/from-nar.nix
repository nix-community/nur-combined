{
substituter ? "https://allvm.cachix.org",
name,
narurl,
narHash
}:

import <nix/fetchurl.nix> {
  url = "${substituter}/${narurl}";
  unpack = true;
  inherit name;

  sha256 = narHash; # downloadHash;
}

