{
  pkgs ? import <nixpkgs> { },
  ...
}:
pkgs.lib.makeScope pkgs.newScope (
  self:
  let
    inherit (self) callPackage;
    p = path: callPackage path { };
  in
  rec {
    hmModules = {
      tmux = ./modules/tmux/home.nix;
      wallpaper = ./modules/wallpaper/home.nix;
    };
    modules = {
      cachix = ./modules/cachix/system.nix;
    };

    #packages = pkgs.recurseIntoAttrs (pkgs.lib.makeScope pkgs.newScope (self: let inherit (self) callPackage; p = path: callPackage path { }; in ({
    # wine packages
    wrapWine = p ./pkgs/wrapWine.nix;
    mspaint = p ./pkgs/wineApps/mspaint.nix;
    pinball = p ./pkgs/wineApps/pinball.nix;

    # custom things
    custom_neovim = p ./pkgs/custom/neovim;

    # utils
    pkg = p ./pkgs/pkg.nix;
    fhsctl = p ./pkgs/fhsctl.nix;
    #};
    lib = {
      filter = import ./lib/filter.nix;
      image2color = import ./lib/image2color.nix;
      importAllIn = import ./lib/importAllIn.nix;
      lsName = import ./lib/lsName.nix;
      pathListIfExist = import ./lib/pathListIfExist.nix;
    };
  }
)
