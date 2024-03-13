{self, global, pkgs, config, lib, ... }@args:
let
  inherit (self) inputs;
  inherit (global) username;
  hostname = "riverwood";
in
{
  imports = [
      ./hardware-configuration.nix
      ../gui-common

      "${self.inputs.nixos-hardware}/common/cpu/intel/kaby-lake"
      "${self.inputs.nixos-hardware}/common/gpu/intel"
      "${self.inputs.nixos-hardware}/common/pc/laptop/ssd"

      ./kvm.nix
      ./networking.nix
      ./plymouth.nix
      ./remote-build.nix
      ./tuning.nix
      ./test_socket_activated
    ]
  ;

  environment.systemPackages = with pkgs; [
    thunderbird
  ];

  services.guix.enable = true;

  services.php-utils.enable = true;

  services.python-microservices.services = {
    teste = {
      script = ''
        from io import StringIO
        from json import dump
        def handler():
          def _ret(self):
            return dict(foi=True)
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            buf = StringIO()
            dump(dict(foi=True), buf)
            return buf
          return _ret
      '';
    };
  };
  services.xserver.windowManager.i3.enable = true;
  # programs.hyprland.enable = true;

  programs.sunshine.enable = true;

  # virtualisation.waydroid.enable = true;

  services.nixgram = {
    enable = true;
    customCommands = {
      ping = "echo pong";
    };
  };

  services.syncthing = {
    enable = true;
    folder-targets = {
      obsidian = "/home/lucasew/WORKSPACE/ZETTEL/obsidian";
    };
    settings = {
      folders = {
        obsidian = {
          label = "Obsidian";
          id = "43a6e881-d9f2-4517-9ba4-22f4a0c41199";
          devices = [ "moto-g52" ];
        };
      };
      devices = {
        moto-g52 = {
          addresses = [ "tcp://moto-g52" ]; # tailscale
          id = "ZZB7S3J-5VVLWXY-OUSSEIS-N5SNGVC-MJVVRK2-7PNVQBE-SI7Z2O4-6GVINAK";
        };
      };
    };
  };

  services.nginx.enable = true;

  boot.plymouth.enable = true;

  services.pocket2kindle.enable = true;
  programs.gamemode.enable = true;

  services.flatpak.enable = true;

  networking.networkmanager.wifi.scanRandMacAddress = true;
  networking.hostId = "dabd2d19";
  services.cockpit.enable = true;

  services.telegram-sendmail.enable = true;

  services.cloud-savegame = {
    enable = true;
    calendar = "01:00:01";
  };

  programs.steam.enable = true;

  services.xserver.xkb.model = "acer_laptop";

  services.simple-dashboardd = {
    enable = true;
    openFirewall = true;
  };

  virtualisation.kvmgt.enable = false;
  virtualisation.spiceUSBRedirection.enable = true;
 
  # programs.steam.enable = true;

  programs.kdeconnect.enable = true;

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

  gc-hold.paths = with pkgs; [
    go gopls
    # zig zls
    # terraform
    # ansible vagrant
    gnumake cmake
    clang gdb ccls
    # python3Packages.pylsp-mypy
    # nodejs yarn
    # openjdk11 maven ant
    docker-compose
    # jre
  ];

  networking.hostName = hostname; # Define your hostname.

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
 
  environment.dotd."/etc/trab/nhaa".enable = true;
  services.screenkey.enable = true;

  # kernel
  boot.kernelPackages = pkgs.linuxPackages_6_1;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?

}
