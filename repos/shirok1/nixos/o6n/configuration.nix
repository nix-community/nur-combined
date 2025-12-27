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
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixo6n"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Hong_Kong";

  # Configure network proxy if necessary
  #networking.proxy.default = "http://192.168.88.190:6152/";
  #networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024;
    }
  ];

  zramSwap.enable = true;

  nixpkgs.overlays = [
    (final: prev: {
      inherit (final.lixPackageSets.stable)
        nixpkgs-review
        nix-direnv
        nix-eval-jobs
        nix-fast-build
        colmena
        ;
    })
  ];

  nix.package = pkgs.lixPackageSets.stable.lix;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    substituters = [
      "https://cache.garnix.io"
      "https://nix-community.cachix.org"
      "https://shirok1.cachix.org"
      "https://cache.numtide.com"
    ];
    trusted-public-keys = [
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "shirok1.cachix.org-1:eKKgSVMjd/6ojQ4QPjEKUHDnMWWempboJ/mIkCFUBc0="
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
    ];
  };
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
      nix-index
      ethtool
      gitui

      llm-agents.codex
    ];
  };

  # programs.firefox.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    git
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    helix
    xh
    nixd
    nil
    htop
    jq
    nvme-cli
    usbutils
    tmux
    zellij
    compose2nix
    nixfmt-rfc-style
    nixfmt-tree
    binutils
    patchelf
    libtree
    ghostty.terminfo
  ];

  environment.etc."vuetorrent".source = "${pkgs.vuetorrent}/share/vuetorrent";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.nexttrace.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  programs.zsh.enable = true;
  programs.fish.enable = true;

  programs.nh = {
    enable = true;
    #clean.enable = true;
    #clean.extraArgs = "--keep-since 4d --keep 3";
    #flake = "/home/user/my-nixos-config"; # sets NH_OS_FLAKE variable for you
  };

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

  services.avahi = {
    enable = true;
    publish.enable = true;
  };

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
        "fruit:model" = "AirPort6";
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
      EP990 = {
        "path" = "/drive/ep990";
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

    prependConfig = ''
      worker_processes auto;
    '';

    eventsConfig = ''
      use epoll;
    '';

    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedGzipSettings = true;
    experimentalZstdSettings = true;

    virtualHosts = {
      "ha.berry.shiroki.tech" = {
        # # Redirect HTTP -> HTTPS
        # forceSSL = true;
        # # Enable ACME (Let's Encrypt). Set to false if you manage certs yourself.
        # enableACME = true;
        # If you enable ACME, also set services.acme.email below (or set
        # services.nginx.extraConfig as needed).
        locations = {
          "/" = {
            proxyPass = "http://[::1]:8123";
            proxyWebsockets = true;
            extraConfig = ''
              proxy_buffering off;
            '';
          };
        };
      };
      "qbt.berry.shiroki.tech" = {
        # # Redirect HTTP -> HTTPS
        # forceSSL = true;
        # # Enable ACME (Let's Encrypt). Set to false if you manage certs yourself.
        # enableACME = true;
        # If you enable ACME, also set services.acme.email below (or set
        # services.nginx.extraConfig as needed).
        locations = {
          "/" = {
            proxyPass = "http://[::1]:8080";
            proxyWebsockets = true;
            extraConfig = ''
              proxy_buffering off;
            '';
          };
        };
      };
      "jellyfin.berry.shiroki.tech" = {
        # # Redirect HTTP -> HTTPS
        # forceSSL = true;
        # # Enable ACME (Let's Encrypt). Set to false if you manage certs yourself.
        # enableACME = true;
        # If you enable ACME, also set services.acme.email below (or set
        # services.nginx.extraConfig as needed).
        locations = {
          "/" = {
            proxyPass = "http://[::1]:8096";
            proxyWebsockets = true;
            extraConfig = ''
              proxy_buffering off;
            '';
          };
        };
      };
    };
  };

  # If you enabled ACME above, configure the email address for registration.
  # Uncomment and set your email if you want automatic Let's Encrypt certs.
  # services.acme = {
  #   acceptTerms = true;
  #   email = "you@example.com";
  #   certs = {
  #     "your.hass.domain" = {
  #       webroot = "/var/www/letsencrypt";
  #     };
  #   };
  # };

  systemd = {
    packages = [ pkgs.qbittorrent-nox ];
    services."qbittorrent-nox@shiroki" = {
      overrideStrategy = "asDropin";
      wantedBy = [ "multi-user.target" ];
    };
    #settings = {
    #  Manager = { RuntimeWatchdogSec = "30s"; WatchdogDevice = "/dev/watchdog0"; };
    #};
  };

  services.home-assistant = {
    enable = true;
    openFirewall = true;
    extraComponents = [
      # Components required to complete the onboarding
      "analytics"
      "google_translate"
      "met"
      "radio_browser"
      "shopping_list"
      # Recommended for fast zlib compression
      # https://www.home-assistant.io/integrations/isal
      "isal"

      "apple_tv"
      "esphome"
      "homekit"
      "homekit_controller"
      "mqtt"
      "mqtt_eventstream"
      "mqtt_json"
      "mqtt_room"
      "mqtt_statestream"
      "ping"
      "qbittorrent"
      "sonos"
      "switchbot"
      "tasmota"
      "thread"
      "upnp"
      "waqi"
      "xiaomi_ble"

      "ffmpeg"
      "zeroconf"
    ];
    config = {
      # Includes dependencies for a basic setup
      # https://www.home-assistant.io/integrations/default_config/
      default_config = { };
      "automation ui" = "!include automations.yaml";
      "scene ui" = "!include scenes.yaml";
      "script ui" = "!include scripts.yaml";

      http = {
        use_x_forwarded_for = true;
        trusted_proxies = [
          "127.0.0.1"
          "::1"
        ];
      };
    };
    customComponents = with pkgs.home-assistant-custom-components; [
      xiaomi_home
    ];
  };

  services.jellyfin = {
    enable = true;
    openFirewall = true;
    user = "shiroki";
  };

  services.clickhouse = {
    enable = true;
    serverConfig = {
      listen_host = "::";
      http_port = 8234;
      tcp_port = 9000;
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
    enable = false;
    package = pkgs.shirok1.snell-server;
    settings = {
      snell-server = {
        listen = "0.0.0.0:13831";
        psk = "this_is_fake";
        ipv6 = "true";
      };
    };
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    80
    443
    8080
    8234
    9000
    13831
    21064 # Home Assistant HomeKit Bridge
    1400 # Home Assistant Sonos
    1443 # Home Assistant Sonos
  ];
  networking.firewall.allowedUDPPorts = [ 13831 ];
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
  system.stateVersion = "25.11"; # Did you read the comment?

}
