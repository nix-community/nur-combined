{
  pkgs,
  lib,
  config,
  vacupkglib,
  ...
}:
let
  inherit (vacupkglib) script;
in
{
  options.vacu.shell.containerAliases = lib.mkEnableOption "container aliases";
  config = lib.mkIf config.vacu.shell.containerAliases {
    vacu.packages = [
      (script "ncrun" ''
        svl_min_args $# 2
        svl_auto_sudo
        container="$1"
        shift
        exec ${lib.getExe pkgs.nixos-container} run "$container" -- "$@"
      '')
      (script "ncrl" ''
        svl_exact_args $# 1
        svl_auto_sudo
        exec ${lib.getExe pkgs.nixos-container} root-login "$1"
      '')
    ];
  };
}
