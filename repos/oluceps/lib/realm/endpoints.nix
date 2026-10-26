{ lib, catalog }:
let
  candidates =
    service: node:
    lib.concatLists (
      lib.mapAttrsToList (
        host: published:
        lib.optional (
          (node == null || node == host) && published ? ${service} && published.${service}.port != null
        ) (published.${service} // { inherit host service; })
      ) catalog
    );
in
{
  inherit candidates;
  resolve =
    {
      service,
      node ? null,
      target ? null,
      verifyID ? null,
    }:
    let
      matches = candidates service node;
      selected = if builtins.length matches == 1 then builtins.head matches else null;
      declaredID = if selected == null then null else selected.serverID or null;
      identity = if verifyID != null then verifyID else declaredID;
    in
    {
      inherit matches selected;
      target =
        if target != null then
          target
        else if selected != null then
          "[${selected.address}]:${toString selected.port}"
        else
          "[::1]:1";
      serverID = if identity == null then "" else identity;
      unambiguous = target != null || selected != null;
      hasIdentity = identity != null && lib.hasPrefix "spiffe://" identity;
      transportMatches =
        target != null || selected == null || (selected.transport or "spiffe-tls") == "spiffe-tls";
      identityMatches =
        target != null || declaredID == null || verifyID == null || verifyID == declaredID;
    };
}
