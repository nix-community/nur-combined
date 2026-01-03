{
  modulesPath,
  config,
  vaculib,
  ...
}:
let
  inherit (vaculib) mkOutOption;
in
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/virtualisation/digital-ocean-config.nix")
  ]
  ++ vaculib.directoryGrabberList ./.;

  options = {
    vacu.liam = {
      shel_domains = mkOutOption [
        # keep-sorted start
        "chat.for.miras.pet"
        "dis8.net"
        "funcache.org"
        "in.jean-luc.org"
        "jean-luc.org"
        "mail.dis8.net"
        "shelvacu.com"
        "shelvacu.miras.pet"
        "shelvacu.net"
        "shelvacu.org"
        "sv.mt"
        # keep-sorted end
      ];
      julie_domains = mkOutOption [
        # keep-sorted start
        "shop.theviolincase.com"
        "theviolincase.com"
        "violingifts.com"
        # keep-sorted end
      ];
      domains = mkOutOption (config.vacu.liam.shel_domains ++ config.vacu.liam.julie_domains);
      relayhosts = {
        allDomains = (mkOutOption "[outbound.mailhop.org]:587") // {
          readOnly = false;
        };
        shelvacuAlt = (mkOutOption "[relay.dynu.com]:587") // {
          readOnly = false;
        };
      };
      reservedIpLocal = mkOutOption "10.46.0.7";
    };
  };

  config = {
    vacu.hostName = "liam";
    vacu.shell.color = "cyan";
    networking.domain = "dis8.net";
    vacu.systemKind = "minimal";

    hardware.enableAllFirmware = false;
    hardware.enableRedistributableFirmware = false;

    # networking.interfaces."ens3".useDHCP = false;
    services.openssh.enable = true;

    virtualisation.digitalOcean.setSshKeys = false;

    users.users.root.openssh.authorizedKeys.keys =
      config.users.users.shelvacu.openssh.authorizedKeys.keys;

    system.stateVersion = "23.11";
  };
}
