{ lib, pkgs, config, ... }:
with lib;                      
let
  cfg = config.services.nix-mirror;
in {
  options.services.nix-mirror = {
    region = mkOption {
      type = types.str;
      default = "global";
    };
  };

  config = {
    nix.settings.substituters = if cfg.region == "china" then lib.mkForce [
      # Select the fastest mirror from China NREN Backbone, CERNET
      # See https://help.mirrors.cernet.edu.cn/nix/
      "https://mirrors.cernet.edu.cn/nix-channels/store/"
    ] else [ "https://cache.nixos.org/" ]; # Fastly Mirror

    system = if pkgs.stdenv.isLinux then {
      # See https://linus.schreibt.jetzt/posts/include-build-dependencies.html
      includeBuildDependencies = cfg.region == "china";
    } else { };
  };
}
