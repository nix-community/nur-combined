{ config, lib, pkgs, ... }:

{
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  environment.systemPackages = with pkgs; [

    # Enable slack screensharing in Wayland
    (pkgs.slack.overrideAttrs (oldAttrs: rec {
      installPhase = builtins.replaceStrings ["UseOzonePlatform" "--ozone-platform=wayland"] ["UseOzonePlatform,WebRTCPipeWireCapturer" ""] oldAttrs.installPhase;
    }))

    zoom-us
    teams
  ];
}
