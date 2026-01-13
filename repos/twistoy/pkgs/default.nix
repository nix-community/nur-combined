{
  pkgs,
  lib,
  newScope,
}:
lib.makeScope newScope
(
  self: let
    inherit (self) callPackage;
  in rec {
    ignore-python = callPackage ./ignore-python {};
    gersemi = callPackage ./gersemi {
      nur-pkgs = {
        inherit ignore-python;
      };
    };
    rime-ls = callPackage ./rime-ls {};
    vimPlugins = pkgs.recurseIntoAttrs (callPackage ./vim-plugins {
      inherit (pkgs.vimUtils) buildVimPlugin;
    });
    distant = callPackage ./distant {};
  }
)
