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
  ] ++ vaculib.directoryGrabberList ./.;

  options = {
    vacu.liam = {
      shel_domains = mkOutOption [
        "shelvacu.com"
        "dis8.net"
        "mail.dis8.net"
        "jean-luc.org"
        "in.jean-luc.org"
        "vacu.store"
        "shelvacu.miras.pet"
        "chat.for.miras.pet"
        "sv.mt"
        "funcache.org"
      ];
      julie_domains = mkOutOption [
        "violingifts.com"
        "theviolincase.com"
        "shop.theviolincase.com"
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
