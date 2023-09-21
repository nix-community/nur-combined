{ lib, config, pkgs, ... }:
let
  inherit (lib) types;
  Model = types.submodule {
    options.weights = lib.mkOption {
      type = types.attrsOf (types.remoteFile { inherit pkgs; });
    };
  };
in
{
  options.models = lib.mkOption{
    type = types.attrsOf Model;
  };
}
