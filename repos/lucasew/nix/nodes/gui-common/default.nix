{
  pkgs,
  lib,
  global,
  ...
}:
let
  inherit (global) username;
in
{
  disabledModules = [
    "services/desktops/dunst.nix"
  ];
  imports = [
    ../common
    ./gui-variants
    ./audio.nix
    ./gui.nix
    ./networking.nix
    ./steam.nix
    ./gammastep.nix
    ./adb.nix
    ./vbox.nix
    ./tuning.nix
    ./gamemode.nix
    ./sunshine.nix
    ./wallpaper.nix
    ./extra-fonts.nix
    ./polkit.nix
  ];

  systemd.settings.Manager = {
    DefaultTimeoutStartSec = "10s";
  };

  environment.systemPackages = with pkgs; [
    parallel
    paper-icon-theme
    p7zip
    unzip # archiving
    pv
    # Extra
    distrobox # plan b
    xkill
    waypipe
    xwayland-satellite
    # GUI utilities
    feh
    fortune
    libnotify
    zenity
    nix-output-monitor
    nbr.wine-apps._7zip
    devenv
  ];

  documentation.man.enable = true;

  programs.dconf.enable = true;
  programs.ydotool.enable = true;
  services.dbus.packages = with pkgs; [ dconf ];
  services.gvfs.enable = true;
  services.tumbler.enable = true;

  # programs.ssh = {
  #   startAgent = true;
  #   extraConfig = ''
  #     ConnectTimeout=5
  #   '';
  # };
  services.shellhub-agent = {
    enable = true;
    tenantId = "c574bf33-a21a-49ef-a7a5-1d8fbd823e4e";
  };
  programs.gnupg.agent = {
    enable = true;
    # enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-gnome3;
  };

  # Users
  users.users = {
    ${username} = {
      description = "Lucas Eduardo";
      extraGroups = [ "ydotool" ];
    };
  };

  hardware.graphics.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = lib.mkDefault true;

  # qt.platformTheme.name = lib.mkDefault "qt5ct";

  # https://github.com/NixOS/nixpkgs/pull/297434#issuecomment-2348783988
  systemd.services.display-manager.environment.XDG_CURRENT_DESKTOP = "X-NIXOS-SYSTEMD-AWARE";
}
