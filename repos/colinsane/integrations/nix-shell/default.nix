# this file exists so that `nix-shell` scripts in my repo can bootstrap their environment.
# use like `#!nix-shell /path/to/this/file.nix --arg f 'ps: [ ps.hello ]'

{ f ? ps: []}: let
  pkgs = import ../../default.nix {};
  buildInputs = f pkgs;
in
  pkgs.mkShell {
    inherit buildInputs;
  }

