{ nixpkgs ? <nixpkgs>, args ? {} }:

import ./default.nix { pkgs = import nixpkgs args; }
