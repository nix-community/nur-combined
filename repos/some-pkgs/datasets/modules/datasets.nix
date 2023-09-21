{ lib, config, pkgs, ... }:
let
  inherit (pkgs.some-lib) types;
in
{
  options.datasets = lib.mkOption {
    type = types.attrsOf (types.remoteFile { inherit pkgs; });
  };
}
