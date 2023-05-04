{ config, lib, sane-data, sane-lib, ... }:

let
  inherit (builtins) head map mapAttrs tail;
  inherit (lib) concatStringsSep mkMerge reverseList;
in
{
  sane.ssh.pubkeys =
  let
    # path is a DNS-style path like [ "org" "uninsane" "root" ]
    keyNameForPath = path:
      let
        rev = reverseList path;
        name = head rev;
        host = concatStringsSep "." (tail rev);
      in
      "${name}@${host}";

    # [{ path :: [String], value :: String }] for the keys we want to install
    globalKeys = sane-lib.flattenAttrs sane-data.keys;
    domainKeys = sane-lib.flattenAttrs (
      mapAttrs (host: cfg: {
        colin = cfg.ssh.user_pubkey;
        root = cfg.ssh.host_pubkey;
      }) config.sane.hosts.by-name
    );
  in mkMerge (map
    ({ path, value }: {
      "${keyNameForPath path}" = lib.mkIf (value != null) value;
    })
    (globalKeys ++ domainKeys)
  );
}
