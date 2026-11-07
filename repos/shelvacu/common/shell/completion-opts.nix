{ lib, ... }:
let
  # run completion functions with these at their defaults, since my interactive settings (tweaks.nix) break some completion scripts
  shoptOff = [
    "dotglob"
    "failglob"
    "globstar"
    "nocaseglob"
    "nocasematch"
    "nullglob"
  ];
  shoptOn = [ "globskipdots" ];
  setOff = [
    "errexit"
    "noclobber"
    "nounset"
    "pipefail"
  ];
in
{
  vacu.shell.idempotentShellLines = ''
    function __vacu__compopts_run() {
      local -
      local __vacu__compopts_saved __vacu__compopts_r
      __vacu__compopts_saved=$(shopt -p ${lib.escapeShellArgs (shoptOff ++ shoptOn)})
      shopt -u ${lib.escapeShellArgs shoptOff}
      shopt -s ${lib.escapeShellArgs shoptOn}
      set +o ${lib.concatStringsSep " +o " (map lib.escapeShellArg setOff)}
      "$@"
      __vacu__compopts_r=$?
      eval "$__vacu__compopts_saved"
      return $__vacu__compopts_r
    }

    function __vacu__compopts_wrap() {
      eval "__vacu__compopts__$1() { __vacu__compopts_run $1 \"\$@\"; }"
    }

    # catches lazily-loaded completions
    function complete() {
      local -a __vacu__compopts_args=("$@")
      local __vacu__compopts_i __vacu__compopts_f
      for ((__vacu__compopts_i = 0; __vacu__compopts_i + 1 < ''${#__vacu__compopts_args[@]}; __vacu__compopts_i++)); do
        [[ ''${__vacu__compopts_args[__vacu__compopts_i]} == -F ]] || continue
        __vacu__compopts_f=''${__vacu__compopts_args[__vacu__compopts_i + 1]}
        [[ $__vacu__compopts_f == __vacu__compopts__* ]] && continue
        __vacu__compopts_wrap "$__vacu__compopts_f"
        __vacu__compopts_args[__vacu__compopts_i + 1]=__vacu__compopts__$__vacu__compopts_f
      done
      builtin complete "''${__vacu__compopts_args[@]}"
    }

    eval "$(builtin complete -p | while read -r line; do
      [[ $line =~ \ -F\ ([^ ]+)\  ]] || continue
      f=''${BASH_REMATCH[1]}
      [[ $f == __vacu__compopts__* ]] && continue
      printf '%s\n' "__vacu__compopts_wrap $f" "''${line/ -F $f / -F __vacu__compopts__$f }"
    done)"
  '';
}
