# Extension mechanism shamelessly stolen from [1].
#
# [1]: https://github.com/hlissner/dotfiles/blob/master/lib/default.nix
{ lib, pkgs, inputs }:
let
  inherit (lib) makeExtensible attrValues foldr;
  inherit (modules) mapModules;

  modules = import ./modules.nix {
    inherit lib;
    self.attrs = import ./attrs.nix { inherit lib; self = { }; };
  };

  mylib = makeExtensible (self:
    mapModules ./. (file: import file { inherit self lib pkgs inputs; })
  );
in
mylib.extend (self: super: foldr (a: b: a // b) { } (attrValues super))
