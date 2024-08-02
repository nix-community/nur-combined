{ config, lib, pkgs, ... }:
let
  trust-dns-nmhook = pkgs.static-nix-shell.mkPython3 {
    pname = "trust-dns-nmhook";
    srcRoot = ./.;
    pkgs = [
      "systemd"
    ];
  };
  cfg = config.sane.services.trust-dns;
  dns = config.sane.dns;
  toml = pkgs.formats.toml { };
  instanceModule = with lib; types.submodule ({ config, name, ...}: {
    options = {
      service = mkOption {
        type = types.str;
        default = "trust-dns-${name}";
        description = ''
          systemd service name corresponding to this instance (used internally and automatically set).
        '';
      };
      port = mkOption {
        type = types.port;
        default = 53;
      };
      listenAddrsIpv4 = mkOption {
        type = types.listOf types.str;
        default = [ "127.0.0.1" ];
        description = ''
          IPv4 addresses to serve requests from.
        '';
      };
      listenAddrsIpv6 = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = ''
          IPv6 addresses to serve requests from.
        '';
      };
      substitutions = mkOption {
        type = types.attrsOf types.str;
        default = {};
        description = ''
          text substitutions to make on the config and zone file before starting trust-dns.
        '';
        example = {
          "%CNAMESELF%" = "lappy";
          "%AWAN%" = ''"$(cat /var/uninsane/wan.txt)"'';
        };
      };
      includes = mkOption {
        type = types.listOf types.str;
        default = [];
        description = ''
          list of paths to cat into the final config.
          non-existent paths are skipped.
          supports shell-style globbing.
        '';
      };
      enableRecursiveResolver = mkOption {
        type = types.bool;
        default = false;
        description = ''
          act as a recursive resolver
        '';
      };
      extraConfig = mkOption {
        type = types.attrs;
        default = {};
      };
    };

    config = {
      extraConfig = lib.mkIf config.enableRecursiveResolver {
        zones = [
          {
            zone = ".";
            zone_type = "Hint";
            stores = {
              type = "recursor";
              # contains the list of toplevel DNS servers, from which to recursively resolve entries.
              roots = "${pkgs.dns-root-data}/root.hints";

              # dnssec, see: <https://github.com/hickory-dns/hickory-dns/issues/2193>
              # probably not needed: the default seems to be that dnssec is disabled
              # enable_dnssec = false;
              #
              # defaults, untuned
              # ns_cache_size = 1024;
              # record_cache_size = 1048576;
            };
          }
        ];
      };
    };
  });

  mkSystemdService = flavor: { includes, listenAddrsIpv4, listenAddrsIpv6, port, substitutions, extraConfig, ... }: let
    sed = "${pkgs.gnused}/bin/sed";
    baseConfig = (
      lib.filterAttrsRecursive (_: v: v != null) config.services.trust-dns.settings
    ) // {
      listen_addrs_ipv4 = listenAddrsIpv4;
      listen_addrs_ipv6 = listenAddrsIpv6;
    };
    configTemplate = toml.generate "trust-dns-${flavor}.toml" (baseConfig //
      (lib.mapAttrs (k: v:
        if k == "zones" then
          # append to the baseConfig instead of overriding it
          (baseConfig."${k}" or []) ++ v
        else
          v
      )
      extraConfig
    ));
    configPath = "/var/lib/trust-dns/${flavor}-config.toml";
    sedArgs = builtins.map (key: ''-e "s/${key}/${substitutions."${key}"}/g"'') (
      # HACK: %ANATIVE% often expands to one of the other subtitutions (e.g. %AWAN%)
      # so we must expand it *first*.
      lib.sortOn
        (k: if k == "%ANATIVE%" then 0 else 1)
        (builtins.attrNames substitutions)
    );
    subs = lib.concatStringsSep " " sedArgs;
  in {
    description = "trust-dns Domain Name Server (serving ${flavor})";
    unitConfig.Documentation = "https://trust-dns.org/";
    after = [ "network.target" ];
    before = [ "network-online.target" ];  # most things assume they'll have DNS services alongside routability
    wantedBy = [ "network.target" ];

    preStart = lib.concatStringsSep "\n" (
      [''
        mkdir -p "/var/lib/trust-dns/${flavor}"
        ${sed} ${subs} -e "" "${configTemplate}" \
          | cat - \
            ${lib.concatStringsSep " " includes} \
            > "${configPath}" || true
      ''] ++ lib.mapAttrsToList (zone: { rendered, ... }: ''
        ${sed} ${subs} -e "" ${pkgs.writeText "${zone}.zone.in" rendered} \
          > "/var/lib/trust-dns/${flavor}/${zone}.zone"
      '') dns.zones
    );

    serviceConfig = (config.systemd.services.hickory-dns or config.systemd.services.trust-dns).serviceConfig // {
      ExecStart = lib.escapeShellArgs ([
        "${lib.getExe config.services.trust-dns.package}"
        "--port"     (builtins.toString port)
        "--zonedir"  "/var/lib/trust-dns/${flavor}"
        "--config"   "${configPath}"
      ] ++ lib.optionals config.services.trust-dns.debug [
        "--debug"
      ] ++ lib.optionals config.services.trust-dns.quiet [
        "--quiet"
      ]);
      # servo/dyn-dns needs /var/lib/uninsane/wan.txt.
      # this might not exist on other systems,
      # so just bind the deepest path which is guaranteed to exist.
      ReadOnlyPaths = [ "/var/lib" ];  #< TODO: scope this down!
    } // lib.optionalAttrs cfg.asSystemResolver {
      # allow the group to write trust-dns state (needed by NetworkManager hook)
      StateDirectoryMode = "775";
    };
  };
in
{
  options = with lib; {
    sane.services.trust-dns = {
      enable = mkOption {
        default = false;
        type = types.bool;
      };
      asSystemResolver = mkOption {
        default = false;
        type = types.bool;
      };
      instances = mkOption {
        default = {};
        type = types.attrsOf instanceModule;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # enable nixpkgs' trust-dns so that i get its config generation
    # but don't actually enable the systemd service... i'll instantiate *multiple* instances per interface further below
    services.trust-dns.enable = true;
    services.trust-dns.settings.zones = [];  #< TODO: remove once upstreamed (bad default)

    # don't bind to IPv6 until i explicitly test that stack
    services.trust-dns.settings.listen_addrs_ipv6 = [];
    services.trust-dns.quiet = true;
    # FIXME(2023/11/26): services.trust-dns.debug doesn't log requests: use RUST_LOG=debug env for that.
    # - see: <https://github.com/hickory-dns/hickory-dns/issues/2082>
    # services.trust-dns.debug = true;

    services.trust-dns.package = pkgs.trust-dns.override {
      rustPlatform.buildRustPackage = args: pkgs.rustPlatform.buildRustPackage (args // {
        buildFeatures = [
          "recursor"
        ];

        # fix enough bugs inside the recursive resolver that it's compatible with my infra.
        # TODO: upstream these patches!
        version = "0.24.1-unstable-2024-07-17";
        src = pkgs.fetchFromGitea {
          domain = "git.uninsane.org";
          owner = "colin";
          repo = "hickory-dns";
          rev = "b4c553e79c160604c8d67cd21c30f460d623de0f";  # Recursor: handle NS responses with a different type and no SOA  (fix: api.mangadex.org., m.wikipedia.org.)
          hash = "sha256-u+1SfLx9Z0AYwIgNKQF7Yy1OK7le8FV5TkD0yQEvW2g=";
          # rev = "67649863faf2e08f63963a96a491a4025aaf8ed6";  # recursor_test: backfill a test for CNAMEs which point to nonexistent records
        };
        cargoHash = "sha256-6Es5/gRqgsteWUHICdgcNlujJE9vrdr3tj/EKKyFsrY=";
      });
    };
    services.trust-dns.settings.directory = "/var/lib/trust-dns";

    users.groups.trust-dns = {};
    users.users.trust-dns = {
      group = "trust-dns";
      isSystemUser = true;
    };

    systemd.services = lib.mkMerge [
      {
        hickory-dns.enable = false;
        hickory-dns.serviceConfig = {
          DynamicUser = lib.mkForce false;
          User = "trust-dns";
          Group = "trust-dns";
          wantedBy = lib.mkForce [];
          # there can be a lot of restarts as interfaces toggle,
          # particularly around the DHCP/NetworkManager stuff.
          StartLimitBurst = 60;
          StateDirectory = lib.mkForce "trust-dns";
        };

        trust-dns.enable = false;
        trust-dns.serviceConfig = {
          DynamicUser = lib.mkForce false;
          User = "trust-dns";
          Group = "trust-dns";
          wantedBy = lib.mkForce [];
          # there can be a lot of restarts as interfaces toggle,
          # particularly around the DHCP/NetworkManager stuff.
          StartLimitBurst = 60;
          StateDirectory = lib.mkForce "trust-dns";
        };
        # trust-dns.unitConfig.StartLimitIntervalSec = 60;
      }
      (lib.mapAttrs'
        (flavor: instanceConfig: {
          name = instanceConfig.service;
          value = mkSystemdService flavor instanceConfig;
        })
        cfg.instances
      )
    ];

    # run a hook whenever networking details change, so the DNS zone can be updated to reflect this
    environment.etc."NetworkManager/dispatcher.d/60-trust-dns-nmhook" = lib.mkIf cfg.asSystemResolver {
      source = "${trust-dns-nmhook}/bin/trust-dns-nmhook";
    };

    # allow NetworkManager (via trust-dns-nmhook) to restart trust-dns when necessary
    # - source: <https://stackoverflow.com/questions/61480914/using-policykit-to-allow-non-root-users-to-start-and-stop-a-service>
    security.polkit.extraConfig = lib.mkIf cfg.asSystemResolver ''
      polkit.addRule(function(action, subject) {
        if (subject.isInGroup("trust-dns") &&
            action.id == "org.freedesktop.systemd1.manage-units" &&
            action.lookup("unit") == "trust-dns-localhost.service") {
          return polkit.Result.YES;
        }
      });
    '';

    sane.services.trust-dns.instances.localhost = lib.mkIf cfg.asSystemResolver {
      listenAddrsIpv4 = [ "127.0.0.1" ];
      listenAddrsIpv6 = [ "::1" ];
      enableRecursiveResolver = true;
      # append zones discovered via DHCP to the resolver config.
      includes = [ "/var/lib/trust-dns/dhcp-configs/*" ];
    };
    networking.nameservers = lib.mkIf cfg.asSystemResolver [
      "127.0.0.1"
      "::1"
    ];
    services.resolved.enable = lib.mkIf cfg.asSystemResolver (lib.mkForce false);
  };
}
