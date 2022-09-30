# SAMPLE NixOs configuration for a minimal instantOS system
# - Boot live medium
# - Follow the install instructions from the NixOS manual

{ config, pkgs, ... }:
let
  # Things you should change

  main_user = "instantuser";
  hostname = "instantOS";

  # run `ip a` to find the values of these
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
    useDHCP = false;  # should be disabled
    # ...instead enable for individual interfaces e.g.:
    # interfaces."${physical_interface}".useDHCP = true;
    # interfaces."${wifi_interface}".useDHCP = true;
  };
  services.xserver = {
    layout = "us";
    xkbVariant = "intl";
    libinput.enable = true;  # Enable touchpad support.
    autorun = true;
  };
  # virtualisation.vmware.guest.enable = true;  # instantOS is a guest of VMWare host
  # virtualisation.virtualbox.guest.enable = true;  # instantOS is a guest of VirtualBox

  #services.printing.enable = true;

  # Below this line, it gets technical, if in doubt, leave alone

  imports = [ ./hardware-configuration.nix ] 
    ++ (if builtins.pathExists ./cachix.nix then [ ./cachix.nix ] else []);

  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  hardware.opengl.driSupport32Bit = true;
  networking.networkmanager.enable = true;
  programs.nm-applet.enable = true;

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
  programs.slock.enable = true;
  services.clipmenu.enable = true;
  services.xserver.exportConfiguration = true;
  programs.dconf.enable = true;
  services.gvfs.enable = true;
  services.xserver.displayManager = {
    defaultSession = "none+instantwm";
    #startx.enable = true;
    gdm.enable = false;
    sddm.enable = false;
  };
  services.xserver.desktopManager = {
    gnome.enable = false;
    plasma5.enable = false;
    xterm.enable = false;
  };
  services.xserver.windowManager = {
    session = pkgs.lib.singleton {
      name = "instantwm";
      start = ''
        startinstantos &
        waitPID=$!
      '';
    };
  };

  # fix java windows
  environment.variables._JAVA_AWT_WM_NONREPARENTING = "1";

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
  security.sudo = {
   enable = true;
   extraConfig = ''
     Defaults    insults
      Cmnd_Alias BOOTCMDS = /sbin/shutdown,/usr/sbin/pm-suspend,/sbin/reboot
      ${main_user} ALL=(root)NOPASSWD:BOOTCMDS
   '';
  };
  fonts.fonts = with pkgs; [ 
    cantarell-fonts
    fira-code
    fira-code-symbols
    dina-font
    joypixels
    (nerdfonts.override { fonts = [ "FiraCode" "FiraMono" ]; })
  ];
  environment.systemPackages = with pkgs; [
    htop gnupg screen tree file
    fasd fzf direnv
    wget curl w3m inetutils dnsutils nmap openssl mkpasswd
    flameshot 
    gitAndTools.git git-lfs
    nix-prefetch-scripts nix-update nixpkgs-review cachix
    nur.repos.instantos.instantnix
    papirus-icon-theme arc-theme
    #gnome3nautilus gsettings-desktop-schemas gnome.dconf-editor
    (neovim.override {viAlias = true; vimAlias = true;})
  ];

  nixpkgs.config.allowUnfree = true;
  nix.autoOptimiseStore = true;
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 14d";
  };
  system.stateVersion = "20.09";
}
