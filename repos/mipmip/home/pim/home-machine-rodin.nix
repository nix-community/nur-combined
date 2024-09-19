{ lib, config, pkgs, ... }:

let
  mkTuple = lib.hm.gvariant.mkTuple;
in
{
  imports = [
    ./home-base-nixos-desktop.nix
    ./files-secondbrain
    ./files-i-am-desktop

    ./hm-modules/programs/smug.nix
  ];

  programs.smug = {
    enable = true;
    projects.blog = {
      root = "~/Developer/blog";
      before_start = [
        "docker-compose -f my-microservices/docker-compose.yml up -d"  # my-microservices/docker-compose.yml is a relative to `root`-al
      ];
      env = {
        FOO = "bar";
      };
      stop = [
        "docker stop $(docker ps -q)"
      ];
      windows = [
        {
          name = "code";
          root = "blog";
          manual = true;
          layout = "main-vertical";
          commands = [
            "docker-compose start"
          ];
          panes = [
            {
              type = "horizontal";
              root = ".";
              commands = [
                "docker-compose exec php /bin/sh"
                "clear"
              ];
            }
          ];
        }

        {
          name = "infrastructure";
          root = "~/Developer/blog/my-microservices";
          layout = "tiled";
          commands = [
            "docker-compose start"
          ];
          panes = [
            {
              type = "horizontal";
              root = ".";
              commands = [
                "docker-compose up -d"
                "docker-compose exec php /bin/sh"
                "clear"
              ];
            }
          ];
        }
      ];

    };
  };


  dconf.settings = {
    "org/gnome/desktop/input-sources" = {
      per-window = false;
      sources = [ (mkTuple [ "xkb" "us" ]) ];
      xkb-options = [

        "altwin:swap_alt_win"

        "grp:alt_shift_toggle"
        "lv3:ralt_switch"
        "compose:ralt"
        "caps:none"];
    };
  };


}
