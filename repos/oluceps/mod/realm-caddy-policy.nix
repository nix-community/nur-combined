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
      caddyID = host: "${config.realm.servicePrefix}caddy-${host}";
      idsFor = map caddyID;
    in
    {
      options.realm.caddy = {
        # One Caddy identity per mesh node, derived from the registry.
        ids = value (lib.types.attrsOf lib.types.str) (
          lib.mapAttrs (host: _: caddyID host) config.realm.serviceDiscovery.nodes
        );
        localID = value lib.types.str policy.ids.${config.networking.hostName};
        entrypointID = value lib.types.str (caddyID "eihort");
      };

      # Receivers reference these roles with `allow.groups`; the group set
      # is the single place that decides which edge reaches which backend.
      config.realm.authorization.groups =
        # caddy-<host>: exactly one node's Caddy.
        lib.mapAttrs' (host: id: lib.nameValuePair "caddy-${host}" [ id ]) policy.ids // {
          # Public HTTPS entrypoints serving the shared nyaw.xyz routes.
          public-caddy = idsFor [
            "abhoth"
            "azasos"
            "eihort"
            "nodens"
          ];
          # Entrypoints carrying the Atuin/Rustypaste routes (eihort via its relay).
          relay-caddy = idsFor [
            "abhoth"
            "eihort"
            "nodens"
          ];
          # The internal entrypoint; sole caller of admin-grade backends.
          entry-caddy = idsFor [ "eihort" ];
          # Entrypoints exposing the Stalwart web API.
          mail-caddy = idsFor [
            "abhoth"
            "nodens"
          ];
        };
    };
}
