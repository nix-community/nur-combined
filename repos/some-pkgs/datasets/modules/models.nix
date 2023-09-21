{ lib, config, pkgs, ... }:
let
  inherit (lib) types;
  inherit (pkgs.some-util.types) RemoteFile;
  Model = types.submodule {
    options.weights = lib.mkOption {
      type = types.attrsOf RemoteFile;
    };
  };
in
{
  options.models = lib.mkOption {
    type = types.attrsOf Model;
  };
}
