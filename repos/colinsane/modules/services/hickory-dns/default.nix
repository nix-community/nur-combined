{ config, lib, pkgs, ... }:
let
  hickory-dns-nmhook = pkgs.static-nix-shell.mkPython3 {
    pname = "hickory-dns-nmhook";
    srcRoot = ./.;
    pkgs = [
      "systemd"
    ];
  };
  cfg = config.sane.services.hickory-dns;
  dns = config.sane.dns;
  toml = pkgs.formats.toml { };
  instanceModule = with lib; types.submodule ({ config, name, ...}: {
    options = {
      service = mkOption {
        type = types.str;
        default = "hickory-dns-${name}";
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
          text substitutions to make on the config and zone file before starting hickory-dns.
        '';
        example = {
          "%CNAMESELF%" = "lappy";
          "%AWAN%" = ''"$(cat /var/lib/dyn-dns/wan.txt)"'';
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
          act as a recursive resolver.

          WARNING: the recursive resolver feature is beta, there are *many* domains that it simply fails to resolve.
        '';
      };
      extraConfig = mkOption {
        type = types.attrs;
        default = {};
      };
    };

    config = {
      extraConfig = {
        directory = "/var/lib/hickory-dns/${name}";
        zones = lib.optionals config.enableRecursiveResolver [
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
    sed = lib.getExe pkgs.gnused;
    baseConfig = (
      lib.filterAttrsRecursive (_: v: v != null) config.services.hickory-dns.settings
    ) // {
      listen_addrs_ipv4 = listenAddrsIpv4;
      listen_addrs_ipv6 = listenAddrsIpv6;
      listen_port = port;
    };
    configTemplate = toml.generate "hickory-dns-${flavor}.toml" (baseConfig //
      (lib.mapAttrs (k: v:
        if k == "zones" then
          # append to the baseConfig instead of overriding it
          (baseConfig."${k}" or []) ++ v
        else
          v
      )
      extraConfig
    ));
    configPath = "/var/lib/hickory-dns/${flavor}-config.toml";
    # HACK: %ANATIVE% often expands to one of the other subtitutions (e.g. %AWAN%)
    subKeys = lib.sortOn
      (k: if k == "%ANATIVE%" then 0 else 1)
      (builtins.attrNames substitutions)
    ;
  in {
    description = "hickory-dns Domain Name Server (serving ${flavor})";
    unitConfig.Documentation = "https://hickory-dns.org/";
    after = [ "network.target" ];
    before = [ "network-online.target" ];  # most things assume they'll have DNS services alongside routability
    wantedBy = [ "network.target" ];

    preStart = ''
      # set -x
      applySubs() {
        local input_="$1"
        ${lib.concatMapStringsSep "\n" (key: ''
          # explicitly don't escape the `substitutions` value:
          # servo uses this for dyn-dns, where %AWAN% is shell expression
          local subst=${substitutions."${key}"}
          local from_=${lib.escapeShellArg key}
          input_="''${input_//$from_/$subst}"
        '') subKeys}
        echo "$input_"
      }

      mkdir -p "/var/lib/hickory-dns/${flavor}"

      # substitute over the `config.toml`:
      config=$(cat "${configTemplate}")
      applySubs "$config" | cat - ${lib.concatStringsSep " " includes} > "${configPath}"

      # substitute over the zones:
      ${lib.concatMapStringsSep "\n" ({ name, value }: ''
        zoneConfig=$(cat ${pkgs.writeText "${name}.zone.in" value.rendered})
        applySubs "$zoneConfig" > "/var/lib/hickory-dns/${flavor}/${name}.zone"
      '') (lib.attrsToList dns.zones)}
    '';

    serviceConfig = config.systemd.services.hickory-dns.serviceConfig // {
      # replace the nixpkgs service's config file with my own flavored config:
      ExecStart = lib.replaceStrings
        [ "${config.services.hickory-dns.configFile}" ]
        [ configPath ]
        config.systemd.services.hickory-dns.serviceConfig.ExecStart;
      # servo/dyn-dns needs /var/lib/dyn-dns/wan.txt.
      ReadOnlyPaths = lib.optionals config.sane.services.dyn-dns.enable [ "/var/lib/dyn-dns" ];
    } // lib.optionalAttrs cfg.asSystemResolver {
      # allow the group to write hickory-dns state (needed by NetworkManager hook)
      StateDirectoryMode = "775";
    };
  };
in
{
  options = with lib; {
    sane.services.hickory-dns = {
      enable = mkEnableOption "hickory DNS server";
      asSystemResolver = mkOption {
        default = false;
        type = types.bool;
        description = ''
          host a recursive DNS resolver on localhost for use by local programs.
          plugs into /etc/resolv.conf so that any glibc application knows to use the resolver.
          N.B.: hickory-dns fails to resolve several domain names as of 2024-10-04, including:
          - abs.twimg.com
          - social.kernel.org
          - pe.usps.com
          - social.seattle.wa.us
          - support.mozilla.org
          - shows.acast.com
        '';
      };
      instances = mkOption {
        default = {};
        type = types.attrsOf instanceModule;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # enable nixpkgs' hickory-dns so that i get its config generation
    # but don't actually enable the systemd service... i'll instantiate *multiple* instances per interface further below
    services.hickory-dns.enable = true;
    services.hickory-dns.settings.zones = [];  #< TODO: remove once upstreamed (bad default)

    # don't bind to IPv6 until i explicitly test that stack
    services.hickory-dns.settings.listen_addrs_ipv6 = [];
    services.hickory-dns.quiet = true;
    # FIXME(2023/11/26): services.hickory-dns.debug doesn't log requests: use RUST_LOG=debug env for that.
    # - see: <https://github.com/hickory-dns/hickory-dns/issues/2082>
    # services.hickory-dns.debug = true;

    # XXX(2024/11/09): uncomment if you want to use hickory-dns as a recursive resolver again
    # services.hickory-dns.package = pkgs.hickory-dns.override {
    #   rustPlatform.buildRustPackage = args: pkgs.rustPlatform.buildRustPackage (args // {
    #     buildFeatures = [
    #       # to find available features: `rg 'feature ='`
    #       "dnssec"  #< else the recursor doesn't compile
    #       # "dnssec-openssl"  #< else dnssec doesn't compile
    #       "dnssec-ring"  #< else dnssec doesn't compile
    #       "recursor"
    #       # "backtrace"
    #       # "dns-over-h3"
    #       # "dns-over-https"
    #       # "dns-over-https-rustls"
    #       # "dns-over-native-tls"
    #       # "dns-over-quic"
    #       # "dns-over-rustls"
    #       # "dns-over-tls"
    #       # "dnssec-openssl"
    #       # "mdns"
    #       # "native-certs"
    #       # "serde"
    #       # "system-config"
    #       # "tokio-runtime"
    #       # "webpki-roots"
    #     ];

    #     # XXX(2024-11-07): upstream hickory-dns has a recursive resolver *almost* as capable as my own.
    #     # it fails against a few sites mine works on:
    #     # - `en.wikipedia.org.`  (doesn't follow the CNAME)
    #     # it fails against sites mine fails on:
    #     # - `social.kernel.org.`
    #     # - `support.mozilla.org.`
    #     # version = "0.25.0-alpha.2";
    #     # src = pkgs.fetchFromGitHub {
    #     #   owner = "hickory-dns";
    #     #   repo = "hickory-dns";
    #     #   rev = "v0.25.0-alpha.2";
    #     #   hash = "sha256-bEVApMM6/I3nF1lyRhd+7YtZuSAwiozRkMorRLhLOBY=";
    #     # };
    #     # cargoHash = "sha256-KFPwVFixLaL9cdXTAIVJUqmtW1V5GTmvFaK5N5SZKyU=";

    #     # fix enough bugs inside the recursive resolver that it's compatible with my infra.
    #     # TODO: upstream these patches!
    #     version = "0.24.1-unstable-2024-08-19";
    #     src = pkgs.fetchFromGitea {
    #       domain = "git.uninsane.org";
    #       owner = "colin";
    #       repo = "hickory-dns";
    #       rev = "4fd7a8305e333117278e216fa9f81984f1e256b6";  # Recursor: handle NS responses with a different type and no SOA  (fix: api.mangadex.org., m.wikipedia.org.)
    #       hash = "sha256-pNCuark/jvyRABR9Hdd60vndppaE3suvTP3UfCfsimI=";
    #     };
    #     cargoHash = "sha256-6yV/qa1CVndHDs/7AK5wVTYIV8NmNqkHL3JPZUN31eM=";
    #   });
    # };
    services.hickory-dns.settings.directory = "/var/lib/hickory-dns";

    users.groups.hickory-dns = {};
    users.users.hickory-dns = {
      group = "hickory-dns";
      isSystemUser = true;
    };

    systemd.services = lib.mkMerge [
      {
        hickory-dns.enable = false;
        hickory-dns.serviceConfig = {
          DynamicUser = lib.mkForce false;
          User = "hickory-dns";
          Group = "hickory-dns";
          wantedBy = lib.mkForce [];
          # there can be a lot of restarts as interfaces toggle,
          # particularly around the DHCP/NetworkManager stuff.
          StartLimitBurst = 60;
          StateDirectory = lib.mkForce "hickory-dns";
        };
        # hickory-dns.unitConfig.StartLimitIntervalSec = 60;
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
    environment.etc."NetworkManager/dispatcher.d/60-hickory-dns-nmhook" = lib.mkIf cfg.asSystemResolver {
      source = lib.getExe hickory-dns-nmhook;
    };

    # allow NetworkManager (via hickory-dns-nmhook) to restart hickory-dns when necessary
    # - source: <https://stackoverflow.com/questions/61480914/using-policykit-to-allow-non-root-users-to-start-and-stop-a-service>
    security.polkit.extraConfig = lib.mkIf cfg.asSystemResolver ''
      polkit.addRule(function(action, subject) {
        if (subject.isInGroup("hickory-dns") &&
            action.id == "org.freedesktop.systemd1.manage-units" &&
            action.lookup("unit") == "hickory-dns-localhost.service") {
          return polkit.Result.YES;
        }
      });
    '';

    sane.services.hickory-dns.instances.localhost = lib.mkIf cfg.asSystemResolver {
      listenAddrsIpv4 = [ "127.0.0.1" ];
      listenAddrsIpv6 = [ "::1" ];
      enableRecursiveResolver = true;
      # append zones discovered via DHCP to the resolver config.
      includes = [ "/var/lib/hickory-dns/dhcp-configs/*" ];
    };
    networking.nameservers = lib.mkIf cfg.asSystemResolver [
      "127.0.0.1"
      "::1"
    ];
    services.resolved.enable = lib.mkIf cfg.asSystemResolver (lib.mkForce false);
  };
}
