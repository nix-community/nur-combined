{ config, lib, sane-data, sane-lib, ... }:

let
  inherit (builtins) attrValues head map mapAttrs tail;
in
{
  sane.ssh.pubkeys =
  let
    # path is a DNS-style path like [ "org" "uninsane" "root" ]
    keyNameForPath = path:
      let
        rev = lib.reverseList path;
        name = head rev;
        host = lib.concatStringsSep "." (tail rev);
      in
      "${name}@${host}";

    # [{ path :: [String], value :: String }] for the keys we want to install
    globalKeys = sane-lib.flattenAttrs sane-data.keys;

    keysForHost = hostCfg: sane-lib.mapToAttrs
      (name: {
        inherit name;
        value = {
          root = hostCfg.ssh.host_pubkey;
        } // (lib.optionalAttrs hostCfg.ssh.authorized {
          colin = hostCfg.ssh.user_pubkey;
        });
      })
      hostCfg.names
    ;
    domainKeys = sane-lib.flattenAttrs (
      sane-lib.joinAttrsets (
        map keysForHost (builtins.attrValues config.sane.hosts.by-name)
      )
    );
  in lib.mkMerge (map
    ({ path, value }: {
      "${keyNameForPath path}" = lib.mkIf (value != null) value;
    })
    (globalKeys ++ domainKeys)
  );

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
    settings.PasswordAuthentication = false;
  };
  sane.ports.ports."22" = {
    protocol = [ "tcp" ];
    visibleTo.lan = true;
    description = lib.mkDefault "colin-ssh";
  };
}
