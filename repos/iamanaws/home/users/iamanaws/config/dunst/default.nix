{
  lib,
  pkgs,
  hostConfig,
  ...
}:
let
  mkDunstScript =
    name: runtimeInputs:
    pkgs.writeShellApplication {
      inherit name runtimeInputs;
      text = builtins.readFile (./scripts + "/${name}");
    };

  dunstScripts = [
    (mkDunstScript "audio.sh" [
      pkgs.dunst
      pkgs.wireplumber
    ])
    (mkDunstScript "brightness.sh" [
      pkgs.brightnessctl
      pkgs.dunst
    ])
    (mkDunstScript "date.sh" [
      pkgs.coreutils
      pkgs.dunst
    ])
    (mkDunstScript "battery.sh" [
      pkgs.dunst
    ])
    (mkDunstScript "cpu-mem.sh" [
      pkgs.coreutils
      pkgs.dunst
      pkgs.procps
    ])
  ];
in
{
  config = lib.optionalAttrs (hostConfig.isGraphical && hostConfig.isLinux) {
    home.packages = dunstScripts;

    services.dunst = {
      enable = true;

      settings = {
        global = {
          enable_posix_regex = true;
          width = "(200,350)";
          height = 300;
          origin = "top-right";
          offset = "10x10";
          transparency = 10;
          frame_color = "#eceff1";
          font = "CaskaydiaCove NF";
          corner_radius = 5;
        };

        urgency_normal = {
          background = "#37474f";
          foreground = "#eceff1";
          timeout = 10;
        };

        osd = {
          set_stack_tag = "osd";
          timeout = 2;
        };
      };
    };
  };
}
