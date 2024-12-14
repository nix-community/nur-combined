{ lib, ... }:
let
  modules = {
    programs = {
      sccache = ./programs/sccache.nix;
    };
    services = {
      activate-linux = ./services/activate-linux.nix;
    };
  };

  all-modules = lib.concatLists [
    (lib.attrValues modules.programs)
    (lib.attrValues modules.services)
  ];
in modules // {
  inherit all-modules;
}
