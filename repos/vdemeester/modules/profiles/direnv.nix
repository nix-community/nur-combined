{ config, lib, ... }:

with lib;
let
  cfg = config.profiles.direnv;
in
{
  options = {
    profiles.direnv = {
      enable = mkOption {
        default = true;
        description = "Enable direnv profile and configuration";
        type = types.bool;
      };
    };
  };
  config = mkIf cfg.enable (mkMerge [
    {
      programs.direnv = {
        enable = true;
        config = {
          whitelist = {
            prefix = [
              "${config.home.homeDirectory}/src/github.com/knative"
              "${config.home.homeDirectory}/src/github.com/openshift"
              "${config.home.homeDirectory}/src/github.com/tektoncd"
              "${config.home.homeDirectory}/src/github.com/vdemeester"
            ];
          };
        };
      };
    }
    (
      mkIf config.profiles.fish.enable {
        programs.direnv.enableFishIntegration = true;
      }
    )
    (
      mkIf config.profiles.zsh.enable {
        programs.direnv.enableZshIntegration = true;
      }
    )
    (
      mkIf config.profiles.bash.enable {
        programs.direnv.enableBashIntegration = true;
      }
    )
  ]);
}
