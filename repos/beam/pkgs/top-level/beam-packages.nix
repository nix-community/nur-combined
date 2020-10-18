{ pkgs, callPackage, wxGTK30, openssl_1_0_2, lib, util }:

with lib.attrsets;
let
  erlang = util.recurseIntoAttrs
    (callPackage ../development/interpreters/erlang/all-versions.nix {
      inherit util;
    });

  pkg = util.recurseIntoAttrs (mapAttrs (_: erlang:
    util.recurseIntoAttrs
    (callPackage ../development/beam-modules/all-versions.nix {
      inherit erlang util;
    })) (util.filterDerivations erlang));

in util.recurseIntoAttrs { inherit erlang pkg; }
