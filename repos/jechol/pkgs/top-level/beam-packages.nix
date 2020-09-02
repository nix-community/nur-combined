{ pkgs, callPackage, wxGTK30, openssl_1_0_2, lib, util }:

with lib.attrsets;
let
  erlangs = (callPackage ../development/interpreters/erlang/all-versions.nix {
    inherit util;
    mainOnly = false;
  });

  main_erlangs = util.recurseIntoAttrs (erlangs.override { mainOnly = true; });

  packages = (mapAttrs (_: erlang:
    util.recurseIntoAttrs
    (callPackage ../development/beam-modules/all-versions.nix {
      inherit erlang util;
      mainOnly = false;
    })) (util.filterDerivations erlangs));

  main_packages = util.recurseIntoAttrs (mapAttrs (_: erlang:
    util.recurseIntoAttrs
    (callPackage ../development/beam-modules/all-versions.nix {
      inherit erlang util;
      mainOnly = true;
    })) (util.filterDerivations main_erlangs));

in util.recurseIntoAttrs {
  all = util.recurseIntoAttrs { inherit erlangs packages; };
  main = util.recurseIntoAttrs {
    erlangs = main_erlangs;
    packages = main_packages;
  };
}
