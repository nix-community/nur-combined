{ global, lib, ... }:

let
  inherit (builtins) attrValues concatStringsSep;
  inherit (lib) flatten;
  ipAttrs = attrValues global.nodeIps;
  ips = flatten (map (attrValues) ipAttrs);
  ipExprs = map (ip: "allow ${ip};") ips;
in {
  services.nginx = {
    enable = true;
    appendHttpConfig = ''
      ${concatStringsSep "\n" ipExprs}
      allow 127.0.0.1;
      allow ::1;
      deny all;
    '';
  };
}
