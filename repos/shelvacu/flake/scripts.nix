{
  lib,
  vaculib,
  vacuRoot,
  allInputs,
  ...
}:
let
  scriptFiles = import /${vacuRoot}/scripts { inherit vaculib; };
in
{
  perSystem =
    {
      pkgs,
      config,
      plainEval,
      common,
      ...
    }:
    let
      callPackage = lib.callPackageWith (
        pkgs
        // {
          vacuWrappedSops = config.packages.sops;
          vacuPlainConfig = plainEval.config;
          inherit allInputs;
        }
      );
    in
    {
      vacuBuildDerivations = (builtins.mapAttrs (_: fn: callPackage fn { }) scriptFiles) // rec {
        dns-update = callPackage /${vacuRoot}/scripts/dns-update/package.nix { inherit (common) dnsEval; };
        dns-zones = dns-update.dnsZones;
        dns-check = dns-update.dnsCheck;
      };
    };
  vacuBuilds = lib.mkMerge [
    (builtins.mapAttrs (_: _: { putInPackages = true; }) scriptFiles)
    {
      dns-update.aliases = [
        "dns"
        "dnsUpdate"
      ];
      dns-zones = {
        aliases = [
          "dnsZones"
          "dnszones"
        ];
        putInPackages = true;
      };
      dns-check = {
        aliases = [
          "dnsCheck"
          "dnscheck"
        ];
        putInChecks = true;
        checkName = "dns";
      };
    }
  ];
}
