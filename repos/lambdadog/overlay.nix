self: super:

let my-lib = import ./lib { pkgs = super; };
    my-pkgs = import ./pkgs { pkgs = super; };
in {
  lib = super.lib // my-lib;
} // my-pkgs
