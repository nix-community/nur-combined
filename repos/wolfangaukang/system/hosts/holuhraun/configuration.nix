{ config, lib, pkgs, hostname, inputs, ... }:

let
  system-lib = import "${inputs.self}/system/lib" { inherit inputs; };
  inherit (system-lib) obtainIPV4Address obtainIPV4GatewayAddress;
  inherit (pkgs) heroic retroarch virt-manager;
  inherit (pkgs.libretro) mgba bsnes-mercury-performance;

in {
  imports =
    [
      inputs.nixos-hardware.nixosModules.system76

      ./disk-setup.nix
      ./hardware-configuration.nix
      "${inputs.self}/system/profiles/sets/workstation.nix"
    ];

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_1;

  networking = {
    interfaces.enp5s0 = {
      useDHCP = false;
      ipv4.addresses = [ {
        address = obtainIPV4Address hostname "brume";
        prefixLength = 24;
      } ];
    };
    defaultGateway = {
      address = (obtainIPV4GatewayAddress "brume" "1");
      interface = "enp5s0";
    };
  };

  profile = {
    moonlander = {
      enable = true;
      ignoreLayoutSettings = true;
    };
    nix = {
      enableAutoOptimise = true;
      enableFlakes = true;
      enableUseSandbox = true;
    };
    sound = {
      enable = true;
      enableOSSEmulation = true;
      pipewire = {
        enable = true;
        enableAlsa32BitSupport = true;
      };
    };
    virtualization = {
      podman.enable = true;
      qemu = {
        enable = true;
        extraPkgs = with pkgs; [ virt-manager ];
        libvirtdGroupMembers = [ "bjorn" ];
      };
    };
    specialisations = {
      gaming = {
        enable = true;
        steam = {
          enable = true;
          enableSteamHardware = true;
          enableGamescope = true;
        };
        # TODO: Find a way to enable options for users
        home = {
          enable = true;
          enableProtontricks = true;
          retroarch = {
            enable = true;
            package = retroarch;
            coresToLoad = [
              mgba
              bsnes-mercury-performance
            ];
          };
          extraPkgs = [ heroic ];
        };
      };
      work.simplerisk.enable = true;
    };
  };

  sops.secrets."machine_id" = {
    sopsFile = ./secrets.yml;
    mode = "0644";
  };

  #environment.etc.machine-id.source = config.sops.secrets."machine_id".path;

  # Extra settings (22.11)
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  system.stateVersion = "23.05"; # Did you read the comment?

}
