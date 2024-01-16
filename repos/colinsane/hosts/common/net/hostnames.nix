{ config, lib, ... }:

{
  # give each host a shortname that all the other hosts know, to allow easy comms.
  networking.hosts = lib.mkMerge (builtins.map
    (host: let
      cfg = config.sane.hosts.by-name."${host}";
    in {
      "${cfg.lan-ip}" = [ host ];
    } // lib.optionalAttrs (cfg.wg-home.ip != null) {
      "${cfg.wg-home.ip}" = [ "${host}-hn" ];
    })
    (builtins.attrNames config.sane.hosts.by-name)
  );
}
