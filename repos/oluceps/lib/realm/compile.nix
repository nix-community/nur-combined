{
  config,
  lib,
  pkgs,
}:
let
  cfg = config.realm;
  common = import ./common.nix {
    inherit
      config
      lib
      pkgs
      cfg
      ;
  };
  outputs = import ./outputs.nix { inherit lib; };
  base = import ./base.nix {
    inherit
      config
      lib
      pkgs
      cfg
      common
      outputs
      ;
  };
  egress = import ./egress.nix {
    inherit
      lib
      pkgs
      cfg
      common
      outputs
      ;
  };
  ingress = import ./ingress.nix {
    inherit
      config
      lib
      pkgs
      cfg
      common
      outputs
      ;
  };
  socks = import ./socks.nix {
    inherit
      lib
      pkgs
      common
      outputs
      ;
  };
  native = import ./native.nix { inherit lib common outputs; };
  workload =
    name: w:
    let
      netUnit = "realm-net-${name}.service";
      context = {
        inherit name w;
        user = common.proxyUser name;
        egressSocket = route: e: if e.socket == null then common.egressPath name route else e.socket;
        network = {
          requires = [ netUnit ];
          after = [ netUnit ];
          bindsTo = [ netUnit ];
          unitConfig.JoinsNamespaceOf = netUnit;
        };
      };
    in
    outputs.merge (
      [ (base context) ]
      ++ lib.mapAttrsToList (egress context) w.egress
      ++ lib.mapAttrsToList (ingress context) w.ingress
      ++ [
        (socks context)
        (native context)
      ]
    );
in
workloads: outputs.merge (lib.mapAttrsToList workload (lib.filterAttrs (_: w: w.enable) workloads))
