# TopLevel configuration file for turtaw (currently my X1 Carbon)
{ config, pkgs, options, ... }:

let
  # TODO: clean up this channel specification...
  unstable = import <nixos-unstable> {};
  secrets = import /etc/nixos/secrets.nix;
  modules = import ../default.nix;
in
{
  imports =
    [
      modules.core.common
      modules.core.pkgs.base
      modules.core.pkgs.ui

      modules.my_udev
    ];

  boot.zfs.enableUnstable = true;
  boot.supportedFilesystems = ["zfs"];
  boot.loader.systemd-boot.enable = true;

  networking.hostId = "8425e349";
  networking.hostName = "turtaw"; # Define your hostname.
  networking.networkmanager = {
    enable = true;
    insertNameservers = ["10.100.0.1"];
    # insertNameservers = ["127.0.0.1" "10.100.0.1"];
    # dns = "none";
  };

  time.timeZone = null;

  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "10.100.0.254/24" ];
      privateKey = secrets.wireguard.privateKey;
      # publicKey = "mF+e1jD+sKGBAgxishCNxHz3FGDl/4tivlNMGWBd3Go=";

      peers = secrets.wireguard.peers;
    };
  };

  fonts = {
    fonts = [
      pkgs.fira-mono
      pkgs.fira-code-symbols
      pkgs.powerline-fonts
    ];
  };

  networking.firewall.checkReversePath = false;
  networking.firewall.allowedTCPPorts = [8000 8001 3306 51820 ];
  networking.firewall.allowedUDPPorts = [ 51820 ];

  services = {
    printing.enable = true;
    tlp.enable = true;
    emacs = {
      enable = true;
      install = true;
      # TODO: fix me!
      package = unstable.emacs;
      defaultEditor = true;
    };

    openssh.enable = false;

    xserver = {
      layout = "dvorak";
      dpi = 120;
      enable = true;
      autorun = true;
      exportConfiguration = true;
      libinput.enable = false;
      synaptics.enable = true;
      displayManager.lightdm.enable = true;

      videoDrivers = [ "intel" ];
      updateDbusEnvironment = true;

      desktopManager.gnome3.enable = true;
      desktopManager.mate.enable = true;
      desktopManager.plasma5.enable = true;
      windowManager.default = "xmonad";
      windowManager.xmonad.enable = true;
      windowManager.xmonad.enableContribAndExtras = true;

      desktopManager.xterm.enable = false;

      # Make caps lock an additional ctrl key
      xkbOptions = "ctrl:nocaps";
    };

    ipfs = {
      enable = false;
      autoMount = false;
    };

    redshift = {
      enable = true;
      latitude = "55.9";
      longitude = "3.1";
    };

    zfs = {
      autoSnapshot.enable = true;
      autoScrub.enable = true;
    };

    illum.enable = true;
  };

  programs.ssh = {
    startAgent = true;
  };

  powerManagement.scsiLinkPolicy = null;
  powerManagement.powertop.enable = true;
  powerManagement.enable = true;
  powerManagement.powerDownCommands = ''
    pkill notify-osd
  '';
  powerManagement.powerUpCommands = ''
    notify-osd &
  '';

  virtualisation = {
    virtualbox.host.enable = true;
    rkt.enable = true;
    docker.storageDriver = "zfs";
    # docker.extraOptions = "--bip=172.254.0.1/16";
    libvirtd.enable = false;
  };

  sound.mediaKeys.enable = true;

  hardware = {
    bluetooth.enable = true;
    opengl.driSupport32Bit = true;
    pulseaudio.support32Bit = true;
    pulseaudio.enable = true;
    pulseaudio.package = pkgs.pulseaudioFull;
    trackpoint = {
      enable = true;
      sensitivity = 1000;
      speed = 1000;
      emulateWheel = true;
      fakeButtons = true;
    };
  };
}
