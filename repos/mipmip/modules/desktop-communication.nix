{ config, lib, pkgs, unstable, ... }:

{
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  environment.systemPackages = with pkgs; [

    # Enable slack screensharing in Wayland
    (unstable.slack.overrideAttrs (oldAttrs: rec {
      installPhase = builtins.replaceStrings ["UseOzonePlatform" "--ozone-platform=wayland"] ["UseOzonePlatform,WebRTCPipeWireCapturer" ""] oldAttrs.installPhase;
    }))

    msmtp

    unstable.whatsapp-for-linux
    zoom-us
    skypeforlinux
    tdesktop
    teams
    unstable.srain
    unstable.tuba

    unstable.himalaya
  ];
}
