{ allInputs, lib, vaculib, vacuRoot, vacuModules, ... }:
# let
#   dnsEval = lib.evalModules {
#     modules = [
#       /${vacuRoot}/common
#       /${vacuRoot}/dns
#     ];
#     specialArgs = {
#       vacuModuleType = "plain";
#       inherit (allInputs) dns;
#       inherit vaculib vacuModules;
#     };
#   };
# in
{
  perSystem = { config, plainConfig, pkgs, ... }:
  let
    dnsEval = plainConfig.extendModules { modules = [ /${vacuRoot}/dns ]; };
  in
  {
    packages = {
      dns = import /${vacuRoot}/scripts/dns {
        inherit pkgs lib vacuRoot;
        inputs = allInputs;
        inherit (dnsEval) config;
        inherit (config.packages) wrappedSops;
      };
      dnsZones = lib.pipe dnsEval.config.vacu.dns [
        (lib.mapAttrsToList (name: config: pkgs.writeText "${name}.zone" (toString config)))
        (pkgs.linkFarmFromDrvs "vacu-dns-zone-files")
      ];
    };
  };
}
