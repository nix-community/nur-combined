{
  flake.modules.nixos.realm-internet =
    { config, lib, ... }:
    let
      hostName = config.networking.hostName;
    in
    {
      imports = [ ../nixosModules/realm-internet.nix ];

      options.realm.workloads = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule {
            options.egress = lib.mkOption {
              type = lib.types.attrsOf (
                lib.types.submodule (
                  { config, ... }:
                  {
                    config.node = lib.mkIf (config.service == "internet-proxy") (lib.mkDefault hostName);
                  }
                )
              );
            };
          }
        );
      };

      config.realm.internet = {
        enable = true;
        allowedIDs = map (n: config.realm.servicePrefix + n) [
          "misskey"
          "grafana"
          "immich-ml"
          "jellyfin"
          "vaultwarden"
          "forgejo"
          "ncps"
          "synapse"
          "calibre"
          "mautrix-telegram"
          "ntfy"
          "subs"
          "pocket-id"
        ];
        extraConnectPolicies.synapse-federation = {
          identities = [ "${config.realm.servicePrefix}synapse" ];
          ports = [ 8448 ];
        };
      };
    };
}
