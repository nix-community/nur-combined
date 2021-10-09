{ lib }:

let
  appNamesDict = {
    "clash-for-windows" = {
      "clash-for-windows" = "cfw";
    };
    "dpt-rp1-py" = {
      "dpt-rp1-py" = "dptrp1";
    };
    "wemeet" = {
      "wemeet" = "wemeetapp";
    };
  };
in
p: appNamesDict.${p} or { ${p} = p; }
