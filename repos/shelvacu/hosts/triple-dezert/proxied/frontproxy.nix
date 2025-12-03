{
  config,
  pkgs,
  lib,
  vaculib,
  ...
}:
let
  # How to register a new domain in acme-dns before deploying the nix config:
  # From trip:
  #   curl http://10.16.237.1/register -X POST
  # add it to /var/lib/acme/.lego/lego-acme-dns-accounts.json
  # add CNAME record that points _acme-challenge.whatever.domain to "fulldomain"
  domains = [
    "shelvacu.com"
    "vacu.store"
  ];
  proxied = lib.pipe config.vacu.proxiedServices [
    lib.attrValues
    (lib.filter (c: c.enable))
  ];
  serviceValidDomainAssertions = map (proxiedConfig: {
    assertion = lib.any (
      availableDomain:
      (lib.hasSuffix ("." + availableDomain) proxiedConfig.domain)
      || (proxiedConfig.domain == availableDomain)
    ) domains;
    message = "proxiedService ${proxiedConfig.name}'s `domain` does not match any of the known domains";
  }) proxied;
  hosts = lib.foldl (
    acc: c:
    let
      name = c.ipAddress;
      val = c.name;
    in
    if c.unixSocket != null then acc else acc // { ${name} = (acc.${name} or [ ]) ++ [ val ]; }
  ) { } proxied;
  certBindMounts = vaculib.mapListToAttrs (
    d:
    lib.nameValuePair "/certs/${d}" {
      hostPath = config.security.acme.certs.${d}.directory;
      isReadOnly = true;
    }
  ) domains;
  socketBindMounts = lib.pipe proxied [
    (lib.filter (c: c.unixSocket != null))
    (map (c: builtins.dirOf c.unixSocket))
    lib.unique
    (vaculib.mapNamesToAttrsConst { isReadOnly = false; })
  ];
  bindMounts = certBindMounts // socketBindMounts;
in
{
  assertions = [ ] ++ serviceValidDomainAssertions;
  security.acme.acceptTerms = true;
  security.acme.defaults = {
    email = "nix-acme@shelvacu.com";
    dnsProvider = "acme-dns";
    environmentFile = pkgs.writeText "acme-dns-config.env" ''
      ACME_DNS_API_BASE=http://10.16.237.1
      ACME_DNS_STORAGE_PATH=/var/lib/acme/.lego/lego-acme-dns-accounts.json
    '';
    postRun = "${pkgs.nixos-container}/bin/nixos-container run frontproxy -- systemctl reload haproxy";
  };

  security.acme.certs = vaculib.mapNamesToAttrs (domain: {
    extraDomainNames = [ "*.${domain}" ];
  }) domains;

  users.groups.acme.gid = 993;

  systemd.services."containers@frontproxy" = {
    wants = [ "network.target" ];
    after = [ "network.target" ];
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
  networking.firewall.allowedUDPPorts = [ 443 ]; # quic!

  containers.frontproxy =
    let
      outer_config = config;
    in
    {
      autoStart = false;
      restartIfChanged = true;
      ephemeral = true;
      inherit bindMounts;
      config =
        { config, ... }:
        {
          system.stateVersion = "23.11";
          users.groups.acme.gid = outer_config.users.groups.acme.gid;
          users.users.haproxy.extraGroups = [ config.users.groups.acme.name ];
          services.haproxy.enable = true;
          services.haproxy.config = import ./haproxy-config.nix { inherit lib domains proxied vaculib; };
          networking.hosts = hosts;
          systemd.tmpfiles.settings."asdf"."/run/haproxy".D = {
            user = "haproxy";
            group = "haproxy";
            mode = vaculib.accessModeStr { user = "all"; };
          };
        };
    };
}
