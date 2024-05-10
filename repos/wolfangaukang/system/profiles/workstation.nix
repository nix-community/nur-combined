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
  # Zerotier IPs
  # TODO: Use a map here
  ips = {
    grimsnes = obtainIPV4Address "grimsnes" "activos";
    surtsey = obtainIPV4Address "surtsey" "activos";
    irazu = obtainIPV4Address "irazu" "activos";
    arenal = obtainIPV4Address "arenal" "activos";
    barva = obtainIPV4Address "barva" "activos";
  };

in
{
  imports = [
    ./graphics.nix
  ];

  networking = {
    # TODO: Use a map here
    hosts = {
      "${ips.grimsnes}" = [ "grimsnes" ];
      "${ips.surtsey}" = [ "surtsey" ];
      "${ips.irazu}" = [ "irazu" ];
      "${ips.arenal}" = [ "arenal" ];
      "${ips.barva}" = [ "barva" ];
    };
    firewall = {
      enable = false;
      allowedTCPPorts = [
        23561 # F;sskjfd
      ];
      allowedUDPPorts = [ ];
    };
    networkmanager.enable = true;
  };

  profile.predicates.unfreePackages = [
    "video-downloadhelper"
    "zerotierone"
  ];

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
