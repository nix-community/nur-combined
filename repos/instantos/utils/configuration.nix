# SAMPLE NixOs configuration for a minimal instantOS system
# - Boot live medium
# - Follow the install instructions from the NixOS manual
# - Before running the install command, copy this to /mnt/etc/nixos/configuration.nix
# You will have to create an ~/.xinitrc on the new system (see sample in this folder)

{ config, pkgs, ... }:
let

  # Things you should change

  main_user = "me";
  hostname = "instantOS";
  physical_interface = "enp0s25";
  wifi_interface = "wlo1";
  # Generate passhash with: mkpasswd -m sha-512  (here for password: instantos):
  passhash = "$6$F5wIacs/7hD$0MLOINKEPAUAtODvbOZlozwKJijR7h765ZHHX1Wd81mTuRBfILEbxzSpgMtu.XdWp/xZabBOTb.mz1Sj8/ezm0";

in {

  # Things you may want to change

  time.timeZone = "Europe/Vienna";
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  boot.tmpOnTmpfs = true;
  networking = {
    hostName = hostname;
    wireless.enable = true;
    useDHCP = false;  # should be disabled
    # ...instead enable for individual interfaces:
    interfaces."${physical_interface}".useDHCP = true;
    interfaces."${wifi_interface}".useDHCP = true;
  };
  services.xserver = {
    layout = "us";
    xkbVariant = "intl";
    libinput.enable = true;  # Enable touchpad support.
    autorun = true;
  };

  # Below this line, it gets technical, if in doubt, leave alone

  imports = [ ./hardware-configuration.nix ];

  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  hardware.opengl.driSupport32Bit = true;

  programs.ssh.extraConfig = ''
    Host gh
      HostName github.com
      User git
  '';

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", MODE="0666", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/class/backlight/%k/brightness"
  '';

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.displayManager = {
      startx.enable = true;
      gdm.enable = false;
      sddm.enable = false;
    };
  services.xserver.desktopManager = {
      gnome3.enable = false;
      plasma5.enable = false;
      xterm.enable = false;
    };

  users.users."${main_user}" = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "networkmanager" "wireshark" "dialout" "disk" "video" "docker" ];
    hashedPassword = passhash;
  };

  environment.variables = { EDITOR = "nvim"; };
  environment.shellAliases = { ll="ls -al --color=auto"; ff="sudo vi /etc/nixos/configuration.nix"; ss="sudo nixos-rebuild switch"; };
  environment.homeBinInPath = true;
  environment.etc."inputrc".text = ''
    "\e[Z": menu-complete
    "\e\e[C": forward-word
    "\e\e[D": backward-word
    "\e[A": history-search-backward
    "\e[B": history-search-forward
  '';
  environment.etc."gitconfig".text = ''
    [alias]
    ci = commit
    co = checkout
    st = status
    d = diff
    lg = log
    fa = fetch --all
  '';
  fonts.fonts = with pkgs; [ dina-font ];
  environment.systemPackages = with pkgs; [
    #open-vm-tools-headless
    htop gnupg screen tree rename file
    fasd fzf yadm pass ripgrep direnv
    wget curl w3m inetutils dnsutils nmap openssl mkpasswd sshfs
    gitAndTools.git git-lfs
    nix-prefetch-scripts
    nur.repos.instantos.instantnix
    (neovim.override {viAlias = true; vimAlias = true;})
  ];

  nixpkgs.config.allowUnfree = true;
  nix.autoOptimiseStore = true;
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 14d";
  };
  system.stateVersion = "20.03";
}
