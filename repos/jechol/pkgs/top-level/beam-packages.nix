{ pkgs, callPackage, wxGTK30, openssl_1_0_2, lib, util }:

with lib.attrsets;
let
  erlangs = (callPackage ../development/interpreters/erlang/all-versions.nix {
    inherit util;
    mainOnly = false;
  });

  # rebar and rebar3 is self contained so that doesn't need to be compiled with every erlang versions,
  # and not compilable on erlang 23.
  rebar = callPackage ../development/tools/build-managers/rebar {
    erlang = erlangs.erlang_22_0;
  };
  rebar3 = callPackage ../development/tools/build-managers/rebar3 {
    erlang = erlangs.erlang_22_0;
  };

  packages = (mapAttrs (_: erlang:
    util.recurseIntoAttrs
    (callPackage ../development/beam-modules/all-versions.nix {
      inherit erlang rebar rebar3 util;
      mainOnly = false;
    })) (util.filterDerivations erlangs));

  main_erlangs = util.recurseIntoAttrs (erlangs.override { mainOnly = true; });

  main_packages = util.recurseIntoAttrs (mapAttrs (_: erlang:
    util.recurseIntoAttrs
    (callPackage ../development/beam-modules/all-versions.nix {
      inherit erlang util;
      mainOnly = true;
    })) (util.filterDerivations main_erlangs));

in util.recurseIntoAttrs {
  all = util.recurseIntoAttrs { inherit erlangs rebar rebar3 packages; };
  main = util.recurseIntoAttrs {
    inherit rebar rebar3;
    erlangs = main_erlangs;
    packages = main_packages;
  };
}
