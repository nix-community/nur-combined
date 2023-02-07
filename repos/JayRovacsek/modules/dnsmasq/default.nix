{ config, pkgs, ... }:
let
  # Config file contents to write to environment.etc locations
  local = import ./local.nix;
  cache = import ./cache.nix;

  etcFunction = import ../../functions/etc.nix;
  # Files to write to etc
  etcConfigs =
    builtins.foldl' (acc: config: acc // etcFunction { inherit config; }) { } [
      local
      cache
    ];

  extraConfig = "\n";
in {
  services.dnsmasq = {
    # inherit extraConfig;

    enable = true;
    alwaysKeepRunning = true;
    resolveLocalQueries = true;
    settings = {
      # See more: https://oss.segetech.com/intra/srv/dnsmasq.conf
      # Uncomment these to enable DNSSEC validation and caching:
      # (Requires dnsmasq to be built with DNSSEC option.)
      dnssec = true;
      conf-file = "${pkgs.dnsmasq.outPath}/share/dnsmasq/trust-anchors.conf";

      # Never forward plain names (without a dot or domain part)
      domain-needed = true;

      # Never forward addresses in the non-routed address spaces.
      bogus-priv = true;

      # Set this (and domain: see below) if you want to have a domain
      # automatically added to simple names in a hosts-file.
      expand-hosts = true;

      # Set the cachesize here.
      cache-size = 10000;

      # For debugging purposes, log each DNS query as it passes through
      # dnsmasq.
      log-queries = true;

      # Include all files in a directory which end in .conf
      conf-dir = "/etc/dnsmasq.d/,*.conf";

      localise-queries = true;
      no-resolv = true;
      log-async = true;
      server = [ "127.0.0.1#8053" ];
    };
  };

  environment.etc = etcConfigs;
  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };

  # By default we spin up dnsmasq assuming stubby then will securely
  # resolve over DoTLS/DoH rather than sending our precious packets out to
  # be observed by the world.
  imports = [ ../stubby ];
}
