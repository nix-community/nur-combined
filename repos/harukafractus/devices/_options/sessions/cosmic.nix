{ lib, pkgs, config, ... }:
with lib;                      
let
  cfg = config.sessions.cosmic;
in {
  options.sessions.cosmic = {
    enable = mkEnableOption "Enable cosmic, the new de by system76";
  };

  config = mkIf cfg.enable {
    services.xserver = {
      enable = true;
      displayManager.sessionPackages = [
        pkgs.cosmic-session
      ];
      # Removes xterm
      excludePackages = [ pkgs.xterm ];
    };


    environment.systemPackages = with pkgs; [
      cosmic-applets
      cosmic-applibrary
      cosmic-bg
      cosmic-comp
      cosmic-design-demo
      cosmic-edit
      cosmic-files
      cosmic-greeter
      cosmic-icons
      cosmic-launcher
      cosmic-notifications
      cosmic-osd
      cosmic-panel
      cosmic-protocols
      cosmic-randr
      cosmic-screenshot
      cosmic-session
      cosmic-settings
      cosmic-settings-daemon
      cosmic-store
      cosmic-term
      cosmic-workspaces-epoch
    ];
  };
}
