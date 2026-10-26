{
  lib,
  nodes,
  hostName,
}:
lib.mapAttrs (
  _: node:
  lib.unique (
    map (addr: builtins.head (lib.splitString "/" addr)) ([ node.unique_addr ] ++ (node.addrs or [ ]))
  )
) (lib.filterAttrs (name: node: name != hostName && !(node.nat or true)) nodes)
