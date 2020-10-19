{ pkgs, ... }:

with pkgs;
with { buildVimPluginFrom2Nix = pkgs.vimUtils.buildVimPluginFrom2Nix; };
{
  distilled-vim = pkgs.callPackage ./distilled-vim { inherit buildVimPluginFrom2Nix; };
  vim-racket = pkgs.callPackage ./vim-racket { inherit buildVimPluginFrom2Nix; };
  vrod = pkgs.callPackage ./vrod { inherit buildVimPluginFrom2Nix; };
}
