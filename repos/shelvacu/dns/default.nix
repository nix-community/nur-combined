{
  dns,
  lib,
  vaculib,
  config,
  ...
}:
let
  inherit (lib) mkOption types singleton;
  inherit (dns.lib.combinators)
    ns
    ttl
    spf
    mx
    ;
  inherit (config.vacu) hosts;
  cloudns = {
    pns51 = {
      domain = "pns51.cloudns.net.";
      ipv4 = "185.136.96.192";
      ipv6 = "2a06:fb00:1::1:192";
    };
    pns52 = {
      domain = "pns52.cloudns.net.";
      ipv4 = "185.136.97.192";
      ipv6 = "2a06:fb00:1::2:192";
    };
    pns53 = {
      domain = "pns53.cloudns.net.";
      ipv4 = "185.136.98.192";
      ipv6 = "2a06:fb00:1::3:192";
    };
    pns54 = {
      domain = "pns54.cloudns.net.";
      ipv4 = "185.136.99.192";
      ipv6 = "2a06:fb00:1::4:192";
    };
  };
  # cloudnsDomains = [
  #   "pns51.cloudns.net."
  #   "pns52.cloudns.net."
  #   "pns53.cloudns.net."
  #   "pns54.cloudns.net."
  # ];
  cloudnsSoa = (
    ttl (60 * 60) {
      nameServer = cloudns.pns51.domain;
      adminEmail = "support@cloudns.net";
      serial = 1970010101; # cloudns takes care of updating the serial
      refresh = 7200;
      retry = 1800;
      expire = 1209600;
      minimum = 3600;
    }
  );
  dkimKeyLiam = {
    name = "2024-03-liam";
    content = "v=DKIM1; k=rsa; s=email; p=MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAqoFR9cwOb+IpvaqrI55zlouWMUk5hjKHQARajqeOev2I6Gc3QIvU8btyhKCJu7pwxr+DxK/9HeqTmweCSXZmLlVZ6LjW80aAg+8l2DyMKZPaTowSQcExfNMwHqI1ByUPx49LQQEzvwv8Lx3To2+JghZNXHUx7gcraoCUQnRNzCMoMsGF25Yyt4piW6SXKWsbWHVXaL2i953PtT6agJYqssnBqPx6wqibrkeB9MbtSw97L5oQDaDLmJzEK54vRjFFV4X6/Q1d3D6M5PH0XGm6WEhrNEPgMAAZ6rBqi+AoXUz9E9B+kE/Zc6krCTiV0Y1uL83RCILaEJIjRsHqgrGRYEIBUb4Z5d4CgB3szixzaFTmG+XAgDLGnAHRNGeOn0bUmj35miLUopzGJgHCUQYjaaXMH4FSQMYBFPVqZ1aSiZO0EC/mbLlFbBy51RYPJQK0IusN4IqaBYw6jZYMEVlLWkNb34bfNtPKwoG4T3UjxmSRpfiNCFjYd4DaOz/FBAvUL9bx+qU7O6EZRtslROaWN18uSt20hBH0SpvEovj7vBgWWqXG/chNS7YSSaf3Tlb3I5NbqbmvwFF0t8uuEtN0Wh26qMuOKx70K90B9FpJBpfIk/w8FQ80kP6spbMN1v1T5fA7oZMV1fOn1IezH4wE5Yk/3dS+OXJ4YiLH/hWfjecCAwEAAQ==";
  };
  dmarc =
    lib.pipe
      [
        # see https://www.rfc-editor.org/rfc/rfc7489.html#section-6.3
        "v=DMARC1"
        "p=reject" # policy = reject all mail that fails DKIM or SPF
        # no need for sp=, policy applies to subdomains by default
        "adkim=s" # match dkim domains strictly (foo.shelvacu.com != shelvacu.com)
        "aspf=s" # match spf domains strictly
        "fo=1" # failure reporting: report a failure if any of dkim or spf fails
        "rua=mailto:dmarc-rua@shelvacu.com!25m"
        "ruf=mailto:dmarc-ruf@shelvacu.com!25m"
      ]
      [
        (map (s: s + ";"))
        (lib.concatStringsSep " ")
      ];
  vacuZoneExtModule =
    { config, ... }:
    {
      imports = [ vacuDomainExtModule ];
      options.vacu.cloudns = mkOption {
        default = true;
        type = types.bool;
      };
      config = lib.mkMerge [
        (lib.mkIf config.vacu.cloudns {
          SOA = cloudnsSoa;
          NS = map (server: ttl (60 * 60) (ns server.domain)) (builtins.attrValues cloudns);
          TTL = lib.mkDefault 300;
        })
        { vacu.defaultCAA = lib.mkDefault true; }
      ];
    };
  vacuDomainExtModule =
    { config, ... }:
    {
      options.vacu = {
        liamMail = mkOption {
          default = false;
          type = types.bool;
        };
        _ancestorHasDMARC = mkOption {
          type = types.bool;
          default = false;
          internal = true;
        };
        defaultCAA = mkOption {
          type = types.bool;
          default = false;
        };
      };
      options.subdomains = mkOption {
        type = types.attrsOf (
          types.submodule [
            { config.vacu._ancestorHasDMARC = config.vacu.liamMail || config.vacu._ancestorHasDMARC; }
            vacuDomainExtModule
          ]
        );
      };
      config = lib.mkMerge [
        (lib.mkIf config.vacu.liamMail {
          MX = singleton (mx.mx 0 "liam.dis8.net.");
          TXT = singleton (
            spf.strict [
              "mx"
              "include:outbound.mailhop.org"
              "a:relay.dynu.com"
            ]
          );
          subdomains."${dkimKeyLiam.name}._domainkey".TXT = singleton dkimKeyLiam.content;
        })
        (lib.mkIf (config.vacu.liamMail && !config.vacu._ancestorHasDMARC) {
          subdomains._dmarc.TXT = singleton dmarc;
        })
        (lib.mkIf (config.vacu.defaultCAA) {
          CAA = [
            {
              issuerCritical = true;
              tag = "issue";
              value = "letsencrypt.org";
            }
            {
              issuerCritical = true;
              tag = "issue";
              value = "sectigo.com"; # sectigo = zerossl
            }
            {
              issuerCritical = true;
              tag = "issuewild";
              value = "letsencrypt.org";
            }
            {
              issuerCritical = true;
              tag = "issuewild";
              value = "sectigo.com";
            }
            {
              issuerCritical = false;
              tag = "iodef";
              value = "mailto:caa-violation@shelvacu.com";
            }
          ];
        })
      ];
    };
  dnsData = {
    propA = [ hosts.prophecy.primaryIp ];
    solisA = [ hosts.solis.primaryIp ];
    doA = [ "138.197.233.105" ];
    inherit cloudns;
    cloudnsNS = map (info: info.domain) (builtins.attrValues cloudns);
  };
in
{
  options.vacu.dns = mkOption {
    type = types.attrsOf (types.submoduleWith {
      modules = [
        vacuZoneExtModule
      ]
      ++ dns.lib.types.zone.getSubModules;
      specialArgs = {
        inherit lib vaculib dns dnsData;
        outerConfig = config;
      };
    });
  };
  config.vacu.dns = vaculib.directoryGrabber ./.;
}
