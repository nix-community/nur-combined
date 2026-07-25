{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.wireguird;

  # Teach wg-quick auto_su to skip sudo when CAP_NET_ADMIN is effective and
  # (for up/save) the config is writable. Inserted just before upstream
  # auto_su(); current context is the end of read_bool(). The @@ new-file
  # line count must match the hunk body or patch(1) errors with "malformed
  # patch" (that was the only fix in 993345fb — not a read_bool rebase).
  wgQuickCapabilityPatch = ../pkgs/wireguird/wg-quick-capability-check.patch;

  wireguard-tools = pkgs.wireguard-tools.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ wgQuickCapabilityPatch ];
  });

  package = cfg.package.override { inherit wireguard-tools; };

  wrapperCapabilities = "cap_net_raw,cap_net_admin+eip";

  mkWrapper = name: {
    owner = "root";
    group = cfg.group;
    capabilities = wrapperCapabilities;
    permissions = "u+rx,g+x";
    source = "${wireguard-tools}/bin/${name}";
  };

  # Prefer the system DNS backend's resolvconf over wireguard-tools' openresolv
  # PATH suffix. With services.resolved, NixOS sets
  # networking.resolvconf.package = config.systemd.package (resolved.nix);
  # with openresolv enabled it is pkgs.openresolv.
  dnsBackendEnabled = config.services.resolved.enable || config.networking.resolvconf.enable;

  wgQuickSource =
    if dnsBackendEnabled then
      pkgs.writeShellScript "wg-quick-wireguird" ''
        export PATH=${lib.getBin config.networking.resolvconf.package}/bin''${PATH:+:$PATH}
        exec ${wireguard-tools}/bin/wg-quick "$@"
      ''
    else
      "${wireguard-tools}/bin/wg-quick";

in
{
  options = {
    programs.wireguird = {
      enable = lib.mkEnableOption "wireguird, a WireGuard GUI";
      package = lib.mkPackageOption pkgs "wireguird" { };
      group = lib.mkOption {
        type = lib.types.str;
        default = "wireguard";
        description = ''
          Group allowed to manage WireGuard tunnels with wireguird.
          Add users with `users.users.<name>.extraGroups = [ "${cfg.group}" ];`.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ package ];

    users.groups.${cfg.group} = { };

    # /etc/wireguard must be group-writable so wg-quick skips auto_su when
    # invoked with CAP_NET_ADMIN (see wg-quick-capability-check.patch).
    systemd.tmpfiles.rules = [
      # setgid so new tunnel configs inherit the wireguard group
      "Z /etc/wireguard 2770 root ${cfg.group} -"
    ];

    security.wrappers = {
      wireguird = {
        owner = "root";
        group = cfg.group;
        capabilities = wrapperCapabilities;
        permissions = "u+rx,g+x";
        source = "${lib.getExe package}";
      };
      wg-quick = mkWrapper "wg-quick" // {
        source = wgQuickSource;
      };
      wg = mkWrapper "wg";
    };

    # wg-quick applies DNS= via resolvconf(8):
    #   resolvconf -a IFACE -m 0 -x   # up
    #   resolvconf -d IFACE -f       # down
    #
    # 1. openresolv (networking.resolvconf.enable): state under /run/resolvconf.
    #    NixOS grants the resolvconf group rwx via ACL; mirror that for the
    #    wireguard group so cap-wrapped wg-quick can update DNS without sudo.
    #    Hook resolvconf's ExecStartPost so ACLs are reapplied when that unit
    #    restarts (e.g. after resolvconf.conf changes).
    #
    # 2. systemd-resolved (services.resolved.enable): resolvconf is resolvectl
    #    and talks D-Bus (SetLinkDNS / SetLinkDomains / RevertLink). CAP_NET_ADMIN
    #    does not skip polkit for these (systemd#18956); allow the wireguard
    #    group. wg-quick -a -x needs set-dns-servers and set-domains (~.);
    #    -d needs revert. See systemd resolvconf-compat.c and
    #    org.freedesktop.resolve1.policy.
    systemd.services.resolvconf.serviceConfig.ExecStartPost =
      lib.mkIf config.networking.resolvconf.enable
        (
          lib.mkAfter [
            "+${pkgs.writeShellScript "wireguird-resolvconf-acl" ''
              ${lib.getExe' pkgs.acl "setfacl"} -R \
                -m group:${cfg.group}:rwx \
                -m default:group:${cfg.group}:rwx \
                /run/resolvconf
            ''}"
          ]
        );

    security.polkit = lib.mkIf config.services.resolved.enable {
      enable = true;
      extraConfig = ''
        polkit.addRule(function(action, subject) {
          var actions = [
            "org.freedesktop.resolve1.revert",
            "org.freedesktop.resolve1.set-dns-servers",
            "org.freedesktop.resolve1.set-domains",
          ];
          if (actions.indexOf(action.id) >= 0 && subject.isInGroup("${cfg.group}")) {
            return polkit.Result.YES;
          }
        });
      '';
    };

    warnings = lib.optionals (!dnsBackendEnabled) [
      ''
        programs.wireguird is enabled but neither networking.resolvconf.enable
        nor services.resolved.enable is set. DNS= lines in WireGuard configs
        will not be applied by wg-quick; enable one of those, or manage DNS
        another way.
      ''
    ];
  };

  meta.maintainers = [ ];
}
