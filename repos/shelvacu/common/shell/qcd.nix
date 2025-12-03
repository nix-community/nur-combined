{
  lib,
  config,
  vacuModuleType,
  vaculib,
  ...
}:
let
  inherit (lib) mkOption types;
  home =
    if vacuModuleType == "nix-on-droid" then
      "/data/data/com.termux.nix/files/home"
    else
      "/home/shelvacu";
in
{
  options.vacu.qcd = mkOption {
    default = { };
    type = types.attrsOf types.path;
  };
  config.vacu.shell.functions.qcd = ''
    svl_exact_args $# 1
    declare the_arg="$1"

    declare base="''${the_arg%%/*}"
    declare rest="''${the_arg:''${#base}}"
    declare path

    if false; then :
    ${lib.pipe config.vacu.qcd [
      (lib.mapAttrsToList (
        alias: path:
        ''elif [[ $base == ${lib.escapeShellArg alias} ]]; then path=${lib.escapeShellArg path}''
      ))
      (lib.concatStringsSep "\n")
    ]}
    fi
    if ! [[ -v path ]]; then
      svl_eprintln "unrecognized alias $base"
      return 1
    fi

    cd -- "$path$rest"
  '';
  config.vacu.qcd = {
    gg = "${home}/dev/gallerygrab";
    ns = "${home}/dev/nix-stuff";
    np = "${home}/dev/nixpkgs";
    dev = "${home}/dev";
    d = "${home}/dev";
  };
}
