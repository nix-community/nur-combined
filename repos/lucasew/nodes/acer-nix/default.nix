# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{self, global, pkgs, config, lib, ... }:
let
  inherit (self) inputs;
  inherit (global) wallpaper username;
  inherit (builtins) storePath;
  hostname = "acer-nix";
in
{
  imports =
    [
      ../common/default.nix
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/gui/system.nix
      inputs.nix-ld.nixosModules.nix-ld
      inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
      inputs.nixos-hardware.nixosModules.common-cpu-intel-kaby-lake
    ]
  ;

  zramSwap = {
    enable = true;
    algorithm = "lzo-rle";
    memoryPercent = 20;
  };
 
  programs.steam.enable = true;

  nixpkgs = {
    config = {
      android_sdk.accept_license = true;
    };
  };

  boot = {
    supportedFilesystems = [ "ntfs" ];
    loader = {
      efi = {
        canTouchEfiVariables = true;
      };
      grub = {
        efiSupport = true;
        #efiInstallAsRemovable = true; # in case canTouchEfiVariables doesn't work for your system
        device = "nodev";
        useOSProber = true;
      };
    };
  };

  services.xserver.displayManager.lightdm = {
    background = wallpaper;
    greeters.enso = {
      enable = true;
      blur = true;
    };
  };

  fonts.fonts = with pkgs; [
    siji
    noto-fonts
    noto-fonts-emoji
    fira-code
  ];

  gc-hold.paths = with pkgs; [
    go gopls
    nodejs yarn
    openjdk11 maven ant
  ];

  services.auto-cpufreq.enable = true;
  # text expander in rust
  services.espanso.enable = true;

  networking.hostName = hostname; # Define your hostname.
  networking.networkmanager.enable = true;
  systemd.extraConfig = ''
  DefaultTimeoutStartSec=10s
  '';
  systemd.services.NetworkManager-wait-online.enable = false;

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp2s0f1.useDHCP = true;
  networking.interfaces.wlp3s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    gparted
    paper-icon-theme
    p7zip unzip # archiving
    pv
    # Extra
    # intel-compute-runtime # OpenCL
    distrobox # plan b
  ];

  programs.dconf.enable = true;
  services.dbus.packages = with pkgs; [ dconf ];
  services.gvfs.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.ssh = {
    startAgent = true;
    extraConfig = ''
      ConnectTimeout=5
    '';
  };
  programs.gnupg.agent = {
    enable = true;
    # enableSSHSupport = true;
    pinentryFlavor = "gnome3";
  };
  hardware = {
    bluetooth.enable = true;
    opengl = {
      enable = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        intel-ocl
        vaapiIntel
      ];
      extraPackages32 = with pkgs.pkgsi686Linux; [
        vaapiIntel
      ];
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    # alsa.enable = true;
    # alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
    media-session.config.bluez-monitor.rules = [
      {
        # Matches all cards
        matches = [ { "device.name" = "~bluez_card.*"; } ];
        actions = {
          "update-props" = {
            "bluez5.reconnect-profiles" = [ "hfp_hf" "hsp_hs" "a2dp_sink" ];
            # mSBC is not expected to work on all headset + adapter combinations.
            "bluez5.msbc-support" = true;
            # SBC-XQ is not expected to work on all headset + adapter combinations.
            "bluez5.sbc-xq-support" = true;
          };
        };
      }
      {
        matches = [
          # Matches all sources
          { "node.name" = "~bluez_input.*"; }
          # Matches all outputs
          { "node.name" = "~bluez_output.*"; }
        ];
        actions = {
          "node.pause-on-idle" = false;
        };
      }
  ];
  };

  services.xserver = {
    layout = "br,us";
    xkbOptions = "grp:win_space_toggle,terminate:ctrl_alt_bksp";
    xkbModel = "acer_laptop";
    xkbVariant = ",";
  };

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  # Themes
  # this is crashing calibre
  # programs.qt5ct.enable = true;

  # Users
  users.users = {
    ${username} = {
      extraGroups = [
        "adbusers"
        "vboxusers"
      ];
      description = "Lucas Eduardo";
    };
  };

  # ADB
  programs.adb.enable = true;
  services.udev.packages = with pkgs; [
    gnome3.gnome-settings-daemon
    android-udev-rules
  ];

  # Redshift
  services.redshift.enable = true;
  location = {
    latitude = -24.0;
    longitude = -54.0;
  };

  virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
    virtualbox.host.enable = true;
    waydroid.enable = true;
  };

  boot.plymouth = {
    enable = true;
  };

  # não deixar explodir
  nix.settings.max-jobs = 3;
  # nix.distributedBuilds = true;
  # nix.buildMachines = [
  #   {
  #     hostName = "mtpc.local";
  #     sshUser = "lucas59356";
  #     system = "x86_64-linux";
  #     maxJobs = 3;
  #     speedFactor = 2;
  #     supportedFeatures = [ "big-parallel" "kvm" ];
  #   }
  # ];
  # kernel
  boot.kernelPackages = pkgs.linuxPackages_5_15;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?

}
