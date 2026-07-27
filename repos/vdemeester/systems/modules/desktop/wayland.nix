{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkEnableOption mkDefault mkForce versionOlder;
  cfg = config.modules.desktop.wayland;
  stable = versionOlder config.system.nixos.release "24.05";
in
{
  options = {
    modules.desktop.wayland = {
      enable = mkEnableOption "Enable wayland desktop";
    };
  };
  config = mkIf cfg.enable {
    # Enable desktop module if not already.
    modules.desktop.enable = true;
    # Force disable xorg desktop module
    modules.desktop.xorg.enable = mkForce false;
    # Hardware Support for Wayland Sway, …
    hardware = {
      # graphics
      opengl = {
        enable = true;
      };
    };
    services = {} // (if stable then {} else {
      libinput = {
	touchpad = {
	  disableWhileTyping = true;
	  additionalOptions = ''
	    Option "Ignore" "on"
	  '';
	};
      };
    });
    environment.systemPackages = with pkgs; [
      qogir-icon-theme
    ];
  };
}
