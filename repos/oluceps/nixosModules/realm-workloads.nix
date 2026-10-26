# SPIFFE workload networking (realm).
#
# Goal: a service can reach its declared peers over authenticated TLS and has no
# route to anything else. Each workload is therefore a small stack of processes
# rather than one trusted daemon:
#
#   application (private namespace, no route out)
#     -> egress Unix socket      systemd-socket-proxyd, or the app directly
#     -> ghostunnel client       runs as realm-<name>, holds the SVID
#     -> direct TLS connection   target compiled from the ingress catalog
#     -> remote ghostunnel       checks the caller against allowedIDs
#     -> ingress socket          adapter in the backend's namespace
#
# The application holds no key and, on the proxy path, never sees the SPIRE
# Agent socket. Authorization is stated by the receiver: an ingress names the
# exact SPIFFE IDs it accepts and ghostunnel enforces that list. DNS only selects
# a candidate address, so it cannot change the expected identity.
#
# Declare a workload next to the service it describes in mod/:
#
#   realm.workloads.example = {
#     unit = "example.service";        # default: <name>.service
#     user = "example";
#     group = "example";
#
#     egress.loki = {                  # this workload acts as a client
#       service = "loki";              # catalog service name
#       localPort = 13030;             # optional loopback adapter
#     };
#
#     ingress.http = {                 # this workload acts as a server
#       port = 18080;
#       backend = {
#         kind = "private-tcp";
#         port = 8080;
#       };
#       service = "example";           # name published in DNS
#       allow.identities = [ "spiffe://nyaw.xyz/service/caddy" ];
#     };
#   };
#
# Backend kinds and runtime isolation are documented in docs/realm.md.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkOption types;
  cfg = config.realm;
  realmTypes = import ../lib/realm/types.nix { inherit lib cfg; };
  compiled = import ../lib/realm/compile.nix { inherit config lib pkgs; } cfg.workloads;
in
{
  imports = [
    ./realm-model.nix
    ./realm-http.nix
  ];
  options.realm = {
    enable = lib.mkEnableOption "SPIFFE workload networking";
    # Identity namespace of every SVID. The discovery DNS domain is separate.
    trustDomain = mkOption {
      type = types.str;
      default = "nyaw.xyz";
    };
    # The only place a SPIFFE ID string is assembled. Every other module
    # composes IDs from these prefixes, so the trust domain appears once and a
    # renamed identity is a one-line change instead of a repository-wide grep.
    servicePrefix = mkOption {
      type = types.str;
      readOnly = true;
      default = "spiffe://${cfg.trustDomain}/service/";
    };
    # Address ingress sockets bind to, normally the node's mesh IPv6 address.
    address = mkOption {
      type = types.str;
      default = config.realm.serviceDiscovery.address;
    };
    ghostunnelPackage = lib.mkPackageOption pkgs "ghostunnel" { };
    # Static helper for the per-workload and per-node jobs that are too small to
    # justify their own binary: socket bridges, the
    # container entrypoint adapters and the SPIRE registration reconciler.
    helperPackage = mkOption {
      type = types.package;
      default = pkgs.callPackage ../pkgs/realm-helper { };
      defaultText = lib.literalExpression "pkgs.callPackage ../pkgs/realm-helper { }";
      description = "Binary implementing the per-namespace helper subcommands.";
    };
    # One entry per service that must talk to, or be reached by, the mesh.
    workloads = mkOption {
      default = { };
      type = realmTypes.workloadType;
    };
  };
  config = mkIf cfg.enable {
    users.groups = lib.mkMerge [
      { realm-proxies = { }; }
      compiled.userGroups
    ];
    users.users = compiled.users;
    systemd.services = compiled.services;
    systemd.sockets = compiled.sockets;
    systemd.tmpfiles.rules = compiled.tmpfiles;
    realm.spire.registrations = compiled.registrations;
    realm.serviceDiscovery.publish = compiled.publications;
    assertions = compiled.assertions ++ [
      {
        assertion = config.realm.serviceDiscovery.enable;
        message = "realm: CoreDNS service discovery must be enabled.";
      }
    ];
  };
}
