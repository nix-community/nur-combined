{
  pkgs,
  lib,
  newScope,
}:
lib.makeScope newScope
(
  self: let
    inherit (self) callPackage;
  in {
    gersemi = callPackage ./gersemi {};
    rime-ls = callPackage ./rime-ls {};
    vimPlugins = pkgs.recurseIntoAttrs (callPackage ./vim-plugins {
      inherit (pkgs.vimUtils) buildVimPlugin;
    });
    distant = callPackage ./distant {};
    lazygit = callPackage ./lazygit {};
  }
)
