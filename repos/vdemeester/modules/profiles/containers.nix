{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.profiles.containers;
in
{
  options = {
    profiles.containers = {
      enable = mkEnableOption "Enable containers profile";
      podman = mkOption {
        default = true;
        description = "Enable podman tools";
        type = types.bool;
      };
      docker = mkEnableOption "Enable docker tools";
    };
  };
  config = mkIf cfg.enable {
    profiles.docker.enable = cfg.docker;
    programs.podman.enable = cfg.podman;
    home.packages = with pkgs; [
      nur.repos.mic92.cntr
      my.ko
      my.yak
      skopeo
    ];
    home.file."bin/kontain.me" = {
      text = ''
        #!${pkgs.stdenv.shell}
        command -v docker >/dev/null && {
          docker run -ti --rm kontain.me/ko/$@
        } || {
          podman run -ti --rm kontain.me/ko/$@
        }
      '';
      executable = true;
    };
  };
}
