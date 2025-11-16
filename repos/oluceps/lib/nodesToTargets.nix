{ lib }:

nodes:
let
  isIPv6 = addr: builtins.match ".*:.*" addr != null;

  filteredNodes = lib.filterAttrs (name: value: value.nat == false) nodes;

  #    [ [ { target_nodens_v6 } { target_nodens_v4 } ]
  #      [ { target_yidhra_v4 } { target_yidhra_v6 } ] ]
  listOfTargetLists = lib.attrsets.mapAttrsToList (
    name: value:
    map (addr: {
      targets = [ addr ];
      labels = {
        name = name;
        city = value.city;
        code = value.iata;
        ip = if isIPv6 addr then "IPv6" else "IPv4";
      };
    }) value.addrs
  ) filteredNodes;

in
lib.flatten listOfTargetLists
