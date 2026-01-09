# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    ../../fragments/lix.nix
    ../../fragments/nh.nix
    ../../fragments/nix-settings.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixopi5"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Asia/Hong_Kong";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://192.168.99.39:6152/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  hardware.graphics.enable = true;

  nixpkgs.config.allowUnfree = true;

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.shiroki = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "audio"
      "video"
      "input"
      "docker"
    ]; # Enable ‘sudo’ for the user.
    shell = pkgs.fish;
    packages = with pkgs; [
      tree
      mesa-demos
      kodi-gbm
      glmark2
      btop
      nurl
      nix-init
      gh
      (fastfetch.override {
        brightnessSupport = false;
        waylandSupport = false;
        x11Support = false;
        xfceSupport = false;
      })
      dua
      dust
      zoxide
      atuin
      eza
      just
      nushell
      mosh
    ];
  };

  # programs.firefox.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    helix
    xh
    nixd
    nil
    htop
    grml-zsh-config
    jq
    nvme-cli
    usbutils
    tmux
    zellij
    compose2nix
    nixfmt
    nixfmt-tree
    binutils
    patchelf
    libtree
  ];

  programs.zsh.enable = true;
  programs.fish.enable = true;

  environment.variables.EDITOR = "hx";

  environment.etc."vuetorrent".source = "${pkgs.vuetorrent}/share/vuetorrent";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.nexttrace.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  virtualisation.docker = {
    enable = true;
    # Set up resource limits
    daemon.settings = {
      experimental = true;
    };
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "vfs objects" = [
          "fruit"
          "streams_xattr"
        ];
        "fruit:metadata" = "stream";
        # "fruit:model" = "MacSamba";
        "fruit:model" = "MacPro6,1";
        "fruit:veto_appledouble" = "no";
        "fruit:nfs_aces" = "no";
        "fruit:wipe_intentionally_left_blank_rfork" = "yes";
        "fruit:delete_empty_adfiles" = "yes";
        "fruit:posix_rename" = "yes";
        "fruit:copyfile" = "yes";
        "kernel oplocks" = "yes";
      };
      homes = {
        "valid users" = "%S, %D%w%S";
        "browseable" = "no";
        "writeable" = "yes";
      };
      Archive = {
        "path" = "/drive/archive";
        "browseable" = "yes";
        "writeable" = "yes";
      };
      Spare = {
        "path" = "/drive/spare";
        "browseable" = "yes";
        "writeable" = "yes";
      };
    };
  };

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
    extraSetFlags = [
      "--accept-dns=false"
    ];
  };

  services.daed = {
    enable = true;
    listen = "0.0.0.0:2023";
    openFirewall = {
      enable = true;
      port = 2023;
    };
  };

  services.nginx = {
    enable = true;
  };

  systemd = {
    packages = [ pkgs.qbittorrent-nox ];
    services."qbittorrent-nox@shiroki" = {
      overrideStrategy = "asDropin";
      wantedBy = [ "multi-user.target" ];
    };
    settings = {
      Manager = {
        RuntimeWatchdogSec = "30s";
        WatchdogDevice = "/dev/watchdog0";
      };
    };
  };

  services.qbittorrent-clientblocker = {
    enable = true;
    package = pkgs.shirok1.qbittorrent-clientblocker;
    settings = {
      checkUpdate = false;
      clientType = "qBittorrent";
      clientURL = "http://127.0.0.1:8080/api";
      clientUsername = "shiroki";
    };
  };

  services.snell-server = {
    enable = true;
    package = pkgs.shirok1.snell-server;
    settings = {
      snell-server = {
        listen = "0.0.0.0:13831";
        psk = "this_is_fake";
        ipv6 = "true";
      };
    };
  };

  services.suwayomi-server = {
    enable = true;
    openFirewall = true;

    settings = {
      server.port = 4567;
      # server = {
      #   basicAuthEnabled = true;
      #   basicAuthUsername = "username";

      #   # NOTE: this is not a real upstream option
      #   basicAuthPasswordFile = ./path/to/the/password/file;
      # };
    };
  };

  services.komga = {
    enable = true;
    port = 4568;
    openFirewall = true;
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    8080
    13831
  ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?

}
