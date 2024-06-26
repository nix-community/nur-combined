{ pkgs
, lib
, ...
}:

{
  imports = [
    ./xserver.nix
  ];

  environment = {
    systemPackages = with pkgs; [
      pantheon.elementary-files
      pantheon-tweaks
    ];
    pantheon.excludePackages = with pkgs; [
      # GNOME Browser
      epiphany
      # Email related stuff
      evolutionWithPlugins
      gnome.geary
    ];
  };
  services = {
    pantheon = {
      apps.enable = false;
      contractor.enable = true;
    };
    xserver = {
      desktopManager.pantheon.enable = true;
      displayManager.lightdm.greeters.pantheon.enable = true;
    };
    displayManager.sddm.enable = lib.mkForce false;
  };
}
