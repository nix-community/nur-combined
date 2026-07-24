{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.wireguird;

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
      wg-quick = mkWrapper "wg-quick";
      wg = mkWrapper "wg";
    };

    # wg-quick pushes DNS= lines through resolvconf(8).  openresolv stores
    # state under /run/resolvconf; NixOS grants the resolvconf group rwx via
    # ACL in networking.resolvconf (see resolvconf.nix).  Mirror that for the
    # wireguard group so cap-wrapped wg-quick can update DNS without sudo.
    # Hook resolvconf's ExecStartPost so ACLs are reapplied when that unit
    # restarts (e.g. after resolvconf.conf changes).
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

    warnings = lib.optionals (!config.networking.resolvconf.enable) [
      ''
        programs.wireguird is enabled but networking.resolvconf.enable is false.
        DNS= lines in WireGuard configs will not be applied by wg-quick unless
        resolvconf is available (enable networking.resolvconf, or manage DNS
        another way e.g. systemd-resolved per-link settings).
      ''
    ];
  };

  meta.maintainers = [ ];
}
