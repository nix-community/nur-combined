{ lib, config, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.vacu.qcd = mkOption {
    default = { };
    type = types.attrsOf types.str;
  };
  config.vacu.shell.functions.qcd = ''
    svl_exact_args $# 1
    declare the_arg="$1"

    declare base="''${the_arg%%/*}"
    declare rest="''${the_arg:''${#base}}"
    declare path=""

    if false; then :
    ${lib.pipe config.vacu.qcd [
      (lib.mapAttrsToList (
        alias: path: "elif [[ $base == ${lib.escapeShellArg alias} ]]; then path=${lib.escapeShellArg path}"
      ))
      (lib.concatStringsSep "\n")
    ]}
    fi
    if ! [[ -v path ]]; then
      svl_eprintln "unrecognized alias $base"
      return 1
    fi
    path="''${path/#\~/$HOME}"
    declare -a addendums=(
      ""
      {.git,}/wt/{master,main}
    )
    declare addendum=""
    for addendum in "''${addendums[@]}"; do
      if [[ -d "$path$addendum" ]]; then
        cd -- "$path$addendum$rest"
        return 0
      fi
    done
    svl_eprintln "alias $base resolved to $path but $path does not exist"
    return 1
  '';
  config.vacu.qcd = rec {
    # keep-sorted start
    bb = "~/dev/beatblock-as-src";
    bbd = "~/dev/beatblock-dissection";
    d = "~/dev";
    dev = d;
    gg = "~/dev/gallerygrab";
    inv = "~/dev/inv6";
    inv6 = inv;
    nod = "~/dev/nix-on-droid";
    np = "~/dev/nixpkgs";
    ns = "~/dev/nix-stuff";
    # keep-sorted end
  };
}
