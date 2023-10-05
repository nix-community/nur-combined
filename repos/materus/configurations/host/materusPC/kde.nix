{ config, pkgs, lib, inputs, materusFlake, materusPkgs, ... }:
let
  westonSddm = pkgs.writeText "weston.ini"
    ''
      [core]
      xwayland=true
      shell=fullscreen-shell.so

      [keyboard]
      keymap_layout=pl

      [output]
      name=DP-3
      mode=1920x1080@240

      [output]
      name=DP-2
      mode=off

      [output]
      name=HDMI-A-3
      mode=off
    ''
  ;
in
{
  services.xserver.displayManager.defaultSession = "plasmawayland";
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.displayManager.sddm.settings = {
    General = {
      DisplayServer = "wayland";
      InputMethod="";
    };
    Theme = {
      CursorTheme = "breeze_cursors";
      CursorSize = "24";
    };
    Wayland = {
      CompositorCommand = "${pkgs.weston}/bin/weston  -c ${westonSddm}";
      
    };
  };
  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.desktopManager.plasma5.phononBackend = "gstreamer";
  services.xserver.desktopManager.plasma5.useQtScaling = true;
  services.xserver.desktopManager.plasma5.runUsingSystemd = true;
  programs.gnupg.agent.pinentryFlavor = "qt";
  environment.plasma5.excludePackages = with pkgs; [ libsForQt5.kwallet libsForQt5.kwalletmanager libsForQt5.kwallet-pam ];
  
  environment.variables = {
    # Old fix for black cursor on amdgpu, seems to work fine now
    #KWIN_DRM_NO_AMS = "1";

    #Fix fo amdgpu crashes
    KWIN_DRM_USE_MODIFIERS="0";
    KWIN_DRM_NO_DIRECT_SCANOUT="1";
  };
  environment.systemPackages = with pkgs; [

  ];
}
