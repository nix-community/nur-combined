{ lib, config, pkgs, ... }:
let
  inherit (pkgs.some-util.types) RemoteFile;
  inherit (lib) types;
in
{
  options.datasets = lib.mkOption {
    type = types.attrsOf RemoteFile;
  };
}
