{
  callPackage
}:

let fetch = { url, sha256 }: callPackage ({ fetchurl }:
  fetchurl { inherit url; inherit sha256; }) {};
in {
  swallow = fetch {
    url = "https://dwm.suckless.org/patches/swallow/dwm-swallow-20200707-8d1e703.diff";
    sha256 = "066q054rj84c5l6n17dv97ab7qw2fl315j4drawllv9idm7drnrs";
  };

  namedscratchpads = fetch {
    url = "https://dwm.suckless.org/patches/namedscratchpads/dwm-namedscratchpads-6.2.diff";
    sha256 = "0i8fph7fs2m8ig1kabrw3yq7hm389kdqjhqkqgql16z6mpbvi453";
  };

  keymodes = fetch {
    url = "https://dwm.suckless.org/patches/keymodes/dwm-keymodes-5.8.2.diff";
    sha256 = "0gklgi1wd8z5sir8zjcacddcs8k43cbiqhbnxwidbjdnwp7f6h5k";
  };
}
