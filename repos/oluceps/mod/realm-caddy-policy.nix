{
  flake.modules.nixos.realm =
    { config, lib, ... }:
    let
      policy = config.realm.caddy;
      value =
        type: default:
        lib.mkOption {
          inherit type default;
          readOnly = true;
        };
      idsFor = hosts: map (host: policy.ids.${host}) hosts;
      relayBackends = idsFor [
        "abhoth"
        "eihort"
        "nodens"
      ];
    in
    {
      config.realm.authorization.groups.public-caddy = policy.publicIDs;
      options.realm.caddy = {
        ids = value (lib.types.attrsOf lib.types.str) (
          lib.genAttrs (lib.unique (
            [
              "abhoth"
              "azasos"
              "eihort"
              "hastur"
              "kaambl"
              "nodens"
              "uubboo"
              "yidhra"
            ]
            ++ builtins.attrNames config.realm.serviceDiscovery.nodes
          )) (host: "${config.realm.servicePrefix}caddy-${host}")
        );
        localID = value lib.types.str policy.ids.${config.networking.hostName};
        entrypointID = value lib.types.str policy.ids.eihort;
        publicIDs = value (lib.types.listOf lib.types.str) (idsFor [
          "abhoth"
          "azasos"
          "eihort"
          "nodens"
        ]);
        allowedIDs = value (lib.types.attrsOf (lib.types.listOf lib.types.str)) (
          lib.genAttrs [
            "calibre"
            "grafana"
            "immich"
            "immich-public-proxy"
            "internal-https"
            "meilisearch"
            "misskey"
            "seaweedfs-s3"
            "synapse"
            "vaultwarden"
          ] (_: policy.publicIDs)
          // {
            atuin = relayBackends;
            rustypaste = relayBackends;
            forgejo = [ policy.entrypointID ];
            pocket-id = [ policy.entrypointID ];
            jellyfin = [ policy.entrypointID ];
            seaweedfs-master = [ policy.entrypointID ];
            ntfy = [ policy.ids.azasos ];
            subs = [ policy.ids.azasos ];
            stalwart-web = idsFor [
              "abhoth"
              "nodens"
            ];
            public-http = [ policy.ids.yidhra ];
          }
        );
      };
    };
}
