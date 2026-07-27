{ lib, pkgs, ... }:

with lib;

{
  config.nix.settings = {
    substituters = [
      "https://dtz-circt.cachix.org"
    ];
    trusted-public-keys = [
      "dtz-circt.cachix.org-1:PHe0okMASm5d9SD+UE0I0wptCy58IK8uNF9P3K7f+IU="
    ];
  };
}
