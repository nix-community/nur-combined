{ lib, buildGoModule, fetchgit }:

buildGoModule rec {
  pname = "unflac";
  version = "3d60f1e9ac6da67d574ca0ce140d5a96364b9776";

  src = fetchgit {
    url = "https://git.sr.ht/~ft/unflac";
    rev = "${version}";
    hash = "sha256-hLEyJOREWZNA3bGdD5nkKf4QpdujRdZVr5vVklClnO4=";
  };

  vendorSha256 = "sha256-f62rQhtkTiY5gIgNYWMwhpZ5f7rSYjxckdGhap1l8mQ=";
  proxyVendor = true;

  doCheck = false;

  meta = with lib; {
    homepage = "https://sr.ht/~ft/unflac/";
    description =
      "A command line tool for fast frame accurate audio image + cue sheet splitting.";
    license = licenses.unfree;
  };
}
