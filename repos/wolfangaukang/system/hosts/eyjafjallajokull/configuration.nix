{ config, lib, hostname, inputs, ... }:

let
  inherit (lib) mkForce;
  inherit (inputs) self;
  system-lib = import "${self}/system/lib" { inherit inputs; };
  inherit (system-lib) obtainIPV4Address obtainIPV4GatewayAddress;

in {
  imports = [
    ./disk-setup.nix
    ./hardware-configuration.nix
    (import "${self}/system/profiles/sets/workstation.nix" { inherit inputs hostname; })
  ];

  networking = {
    interfaces.enp0s25 = {
      useDHCP = false;
      ipv4.addresses = [ {
        address = obtainIPV4Address hostname "brume";
        prefixLength = 24;
      } ];
    };
    defaultGateway = {
      address = (obtainIPV4GatewayAddress "brume" "1");
      interface = "enp0s25";
    };
    hostName = hostname;
  };

  profile = {
    nix = {
      enableAutoOptimise = true;
      enableFlakes = true;
      enableUseSandbox = true;
    };
    mobile-devices = {
      android.enable = true;
      ios.enable = true;
    };
    sound = {
      enable = true;
      enableOSSEmulation = true;
      pipewire = {
        enable = true;
        enableAlsa32BitSupport = true;
      };
    };
    virtualization.podman.enable = true;
  };

  # Thinkpad brightness
  hardware.acpilight.enable = true;
  services.illum.enable = true;
  users.extraGroups.video.members = [ "bjorn" ];

  # Extra settings (22.11)
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  system.stateVersion = "20.09";

  specialisation.simplerisk = {
    inheritParentConfig = true;
    configuration = {
      profile = {
        virtualization.podman.enable = mkForce false;
        work.simplerisk.enable = true;
      };
      home-manager.users.bjorn.defaultajAgordoj.work.simplerisk.enable = true;
    };
  };
}

