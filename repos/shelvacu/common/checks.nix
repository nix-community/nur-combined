{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) types;
in
{
  options.vacu.checks = lib.mkOption {
    type = types.attrsOf types.package;
    default = { };
  };
  options.vacu.textChecks = lib.mkOption {
    type = types.attrsOf types.lines;
    default = { };
  };
  config.vacu.checks = lib.mapAttrs (
    name: lines:
    pkgs.runCommand "vacu-textChecks-${name}" { } ''
      (
        set -xev
        ${lines}
        touch "$out"
      )
    ''
  ) config.vacu.textChecks;
}
