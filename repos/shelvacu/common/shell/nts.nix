{ vacupkglib, ... }:
let
  inherit (vacupkglib) script;
  nts_common = is_function: ''
    ${
      if is_function then
        ''
          if (( $# > 1 )); then
            svl_err "only 1 arg at most"
            return 1
          fi
        ''
      else
        ''
          svl_max_args $# 1
        ''
    }
    declare tempdir suffix="-vacu-nts"
    if (( $# > 0 )); then
      suffix="''${suffix}-$1"
    fi
    tempdir="$(mktemp -d --suffix="$suffix")"
    pushd -- "$tempdir"
    declare -i exit_code
    svl_capture_exit_code_into exit_code "$SHELL"
    echo "temp shell exited with code $exit_code" >&2
    popd
    if rmdir -- "$tempdir" 2>/dev/null; then
      echo "Automatically removed empty tempdir $tempdir"
    else
      printf "ls -Al -- %q\n" "$tempdir"
      ls -Al -- "$tempdir"
      declare do_delete
      svl_ask "Do you want to rm -rf $tempdir?" --result-var do_delete --default-no --short-yes
      if [[ $do_delete == true ]]; then
        rm -rf -- "$tempdir"
      fi
    fi
  '';
in
{
  vacu.packages = [ (script "nts" (nts_common false)) ];
  vacu.shell.functions.nts = nts_common true;
}
