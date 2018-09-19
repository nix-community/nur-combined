{ lib, pkgs, ... }:

with lib;

{
  config = {
    nix = {
      binaryCaches = [
        "https://allvm.cachix.org"
      ];
      binaryCachePublicKeys = [
        "allvm.cachix.org-1:nz7VuSMfFJDKuOc1LEwUguAqS07FOJHY6M45umrtZdk="
      ];
    };
  };
}
