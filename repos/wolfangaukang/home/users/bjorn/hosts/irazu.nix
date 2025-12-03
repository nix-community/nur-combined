{
  inputs,
  pkgs,
  osConfig,
  localLib,
  lib,
  config,
  ...
}:

let
  inherit (inputs) self;
  displays = lib.importJSON "${self}/misc/displays.json";
  profiles = localLib.getNixFiles "${self}/home/users/bjorn/profiles/" [
    "sway"
    "workstation"
  ];

in
{
  imports = profiles ++ [ "${self}/home/users/bjorn" ];

  home = {
    packages = with pkgs; [
      gimp
      musescore
    ];
    persistence =
      let
        allowOther = osConfig.programs.fuse.userAllowOther;
      in
      {
        "/mnt/performance/home/bjorn" = {
          inherit allowOther;
          directories = [
            "Ludoj"
            "Torrentoj"
            "VMs"
          ];
        };
        "/mnt/persist/home/bjorn" = { inherit allowOther; };
      };
  };

  personaj = {
    gaming =
      let
        customRetroarch = (
          pkgs.retroarch.withCores (
            cores: with cores; [
              mgba
              bsnes-mercury-performance
            ]
          )
        );
      in
      {
        enable = osConfig.profile.specialisations.gaming.indicator;
        enableProtontricks = true;
        extraPkgs = with pkgs; [
          heroic
          customRetroarch
        ];
      };
  };

  programs = {
    kitty.font.size = lib.mkForce 10;
    waybar.settings.mainBar.output = [ "HDMI-A-1" ];
  };

  wayland.windowManager.sway.config.output."${displays.ofi.id}".bg =
    "${config.home.homeDirectory}/.wallpaper.jpg fill";
}
