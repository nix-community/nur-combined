{ pkgs, callPackage, wxGTK30, openssl_1_0_2, lib, util }:

with lib.attrsets;
let
  erlang = (callPackage ../development/interpreters/erlang/all-versions.nix {
    inherit util;
    mainOnly = true;
  });

  # rebar and rebar3 is self contained so that doesn't need to be compiled with every erlang versions,
  # and not compilable on erlang 23.
  # rebar = callPackage ../development/tools/build-managers/rebar {
  #   erlang = erlang.erlang_22_0;
  # };
  # rebar3 = callPackage ../development/tools/build-managers/rebar3 {
  #   erlang = erlang.erlang_22_0;
  # };

  pkg = (mapAttrs (_: erlang:
    util.recurseIntoAttrs
    (callPackage ../development/beam-modules/all-versions.nix {
      inherit erlang util;
      mainOnly = true;
    })) (util.filterDerivations erlang));

  # main_erlang = util.recurseIntoAttrs (erlang.override { mainOnly = true; });

  # main_pkg = util.recurseIntoAttrs (mapAttrs (_: erlang:
  #   util.recurseIntoAttrs
  #   (callPackage ../development/beam-modules/all-versions.nix {
  #     inherit erlang util;
  #     mainOnly = true;
  #   })) (util.filterDerivations main_erlang));

in util.recurseIntoAttrs { inherit erlang pkg; }
