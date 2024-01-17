# Some programs allow to place their configuration files either in the users
# home directory or in a system-wide location. This module leverages the
# configuration collection from the home-manager project to configure some
# programs system-wide.
#
# Usage:
#
# Write your NixOS module with a `homeconfig` prefix like so:
#
# {
#    homeconfig.programs.mpv = {
#       enable = true;
#       # ...
#    };
# }
#
# More home-manager options can be found here:
# https://nix-community.github.io/home-manager/options.html#opt-programs.mpv.enable

{ pkgs, lib, ... }:

let
  evalhmconfig = config:
    (import "${pkgs.home-manager.src}/modules" {
      inherit pkgs;
      configuration = { ... }: {
        imports = [ config.homeconfig ];
        # simulate state version. needed for flake build.
        home.stateVersion = "23.05";
        home.username = "user";
        home.homeDirectory = "/home/user/";
      };
    }).config;
in
{
  imports = [
    # mpv
    ({ config, ... }:
      let hmconfig = evalhmconfig config;
      in {
        # write the config files from  ~/.config/mpv into /etc
        environment = lib.mkIf
          (config.services.xserver.enable && hmconfig.programs.mpv.enable)
          {
            etc."mpv/input.conf".text =
              lib.mkIf (hmconfig.xdg.configFile ? "mpv/input.conf")
                hmconfig.xdg.configFile."mpv/input.conf".text;
            etc."mpv/mpv.conf".text =
              lib.mkIf (hmconfig.xdg.configFile ? "mpv/mpv.conf")
                hmconfig.xdg.configFile."mpv/mpv.conf".text;
            systemPackages = [ hmconfig.programs.mpv.package ];
            variables.MPV_HOME = "/etc/mpv";
          };
      })
    # readline
    ({ config, ... }:
      let hmconfig = evalhmconfig config;
      in {
        assertions = [{
          assertion = hmconfig.programs.readline.includeSystemConfig == false;
          message =
            "Readline system config cannot be included in home-manager modules";
        }];
        # write the config file from ~/.inputrc into /etc
        environment.etc."inputrc".text =
          lib.mkIf (hmconfig.home.file ? ".inputrc")
            hmconfig.home.file.".inputrc".text;
      })
    # zathura
    ({ config, ... }:
      let hmconfig = evalhmconfig config;
      in {
        # write the config file from  ~/.config/zathura into /etc
        environment = lib.mkIf
          (config.services.xserver.enable && hmconfig.programs.zathura.enable)
          {
            etc."zathurarc".text =
              hmconfig.xdg.configFile."zathura/zathurarc".text;
            systemPackages = [ hmconfig.programs.zathura.package ];
          };
      })
  ];

  # placeholder for home-manager config
  options.homeconfig = lib.mkOption {
    type = lib.types.submodule { freeformType = lib.types.anything; };
  };

  meta.maintainers = with lib.maintainers; [ nagy ];
}
