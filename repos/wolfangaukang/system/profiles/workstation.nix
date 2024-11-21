# Profile for physical devices
{ inputs
, lib
, hostname
, ...
}:

let
  inherit (inputs) self;
  localLib = import "${self}/lib" { inherit inputs lib; };
  inherit (localLib) obtainIPV4Address;
  hostList = [ "grimsnes" "surtsey" "irazu" "arenal" "barva" ];
  zerotierIps = builtins.listToAttrs (map (host: { name = host; value = obtainIPV4Address "${host}" "activos"; }) hostList);

in
{
  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = false;
    };
    pulseaudio.enable = lib.mkForce false;
    graphics.enable = true;
  };
  networking = {
    hosts = builtins.listToAttrs (map (host: { name = "${zerotierIps.${host}}"; value = [ "${host}" ]; }) hostList );
    firewall = {
      enable = false;
      allowedTCPPorts = [
        23561 # F;sskjfd
      ];
      allowedUDPPorts = [ ];
    };
    networkmanager.enable = true;
  };

  profile = {
    specialisations.work.simplerisk.enable = true;
    predicates.unfreePackages = [
      "video-downloadhelper"
      "zerotierone"
    ];
  };

  # Remember to add users to the rfkillers group
  security = {
    doas.extraConfig = ''
      permit nopass :rfkillers as root cmd /run/current-system/sw/bin/rfkill
    '';
    sudo.extraConfig = ''
      %rfkillers ALL=(root) NOPASSWD: /run/current-system/sw/bin/rfkill
    '';
  };

  services = {
    pipewire = {
      audio.enable = true;
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      jack.enable = true;
      pulse.enable = true;
    };
    openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
      listenAddresses = [
        {
          addr = "0.0.0.0";
          port = 17131;
        }
        {
          addr = (obtainIPV4Address hostname "activos");
          port = 22;
        }
      ];
      hostKeys = [
        {
          bits = 4096;
          path = "/persist/etc/ssh/ssh_host_rsa_key";
          type = "rsa";
        }
        {
          path = "/persist/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];
    };
    zerotierone = {
      enable = true;
      joinNetworks = [ "a09acf02337dcfe5" ];
    };
  };

  time.timeZone = "America/Costa_Rica";
}
