{
  lib,
  modulesPath,
  config,
  vaculib,
  dnsEval,
  ...
}:
let
  inherit (vaculib) mkOutOption;
  recurse =
    path:
    lib.mapAttrsToList (
      name: value:
      let
        subPath = "${name}.${path}";
      in
      [ ] ++ (lib.optional value.vacu.liamMail subPath) ++ (recurse subPath value.subdomains)
    );
  domains = lib.pipe (recurse "" dnsEval.config.vacu.dns) [
    lib.flatten
    (map (lib.removeSuffix "."))
  ];
  julie_domains = [
    # keep-sorted start
    "shop.theviolincase.com"
    "theviolincase.com"
    "violingifts.com"
    # keep-sorted end
  ];
  shel_domains = builtins.filter (d: !(builtins.elem d julie_domains)) domains;
in
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/virtualisation/digital-ocean-config.nix")
  ]
  ++ vaculib.directoryGrabberList ./.;

  options = {
    vacu.liam = (vaculib.mkOutOptions { inherit domains julie_domains shel_domains; }) // {
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
