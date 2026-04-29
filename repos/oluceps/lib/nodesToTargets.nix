{ lib }:

nodes:
let
  # isIPv6 = addr: builtins.match ".*:.*" addr != null;

  filteredNodes = lib.filterAttrs (name: value: value.nat == false) nodes;

  listOfTargetLists = lib.attrsets.mapAttrsToList (name: value: {
    targets = [ value.unique_addr_nomask ];
    labels = {
      name = name;
      city = value.city;
      code = value.iata;
      ip = value.unique_addr_nomask;
    };
  }) filteredNodes;

in
lib.flatten listOfTargetLists
