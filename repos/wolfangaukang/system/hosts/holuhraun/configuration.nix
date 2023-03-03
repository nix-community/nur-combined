{ config, lib, pkgs, hostname, inputs, ... }:

let
  inherit (lib) mkForce;
  inherit (inputs) self;
  system-lib = import "${self}/system/lib" { inherit inputs; };
  inherit (system-lib) obtainIPV4Address obtainIPV4GatewayAddress;

in {
  imports =
    [
      ./disk-setup.nix
      ./hardware-configuration.nix
      (import "${self}/system/profiles/sets/workstation.nix" { inherit inputs hostname; })
    ];

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
    hostName = hostname;
  };

  profile = {
    gaming = {
      enable = true;
      useSteamHardware = true;
    };
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
  };

  system.stateVersion = "21.05"; # Did you read the comment?

  specialisation.simplerisk = {
    inheritParentConfig = true;
    configuration = {
      profile = {
        virtualization = {
          qemu.enable = mkForce false;
          podman.enable = mkForce false;
        };
        work.simplerisk.enable = true;
      };
      home-manager.users.bjorn.defaultajAgordoj.work.simplerisk.enable = true;
    };
  };
}
