# These are the things that might in a simpler time go in ~/.bashrc as aliases. But they're not aliases, cuz aliases are bad
{
  pkgs,
  lib,
  config,
  vacupkglib,
  ...
}:
let
  inherit (vacupkglib) script scriptWith;
  simple = vacupkglib.aliasScript;
  ms_text = with_sudo: ''
    svl_minmax_args $# 1 2
    host="$1"
    session_name="''${2:-main}"
    set -x
    mosh -- "$host" ${lib.optionalString with_sudo "sudo"} tmux new-session -A -s "$session_name"
  '';
  systemctl = "${pkgs.systemd}/bin/systemctl";
  journalctl = "${pkgs.systemd}/bin/journalctl";

  alt_default_installables = ''
    declare -a new_args
    declare arg
    while (( $# > 0 )); do
      arg="$1"
      shift
      if [[ $arg == -- || $arg == --command ]]; then
        new_args+=("$arg" "$@")
        shift $#
        break
      fi
      if [[ $arg != -* && $arg != *#* && $arg != *:* ]]; then
        arg="nixpkgs#$arg"
      fi
      new_args+=("$arg")
    done
  '';
in
{
  imports = [
    {
      vacu.packages = {
        altcaps-copy.enable = config.vacu.isGui;
        altcaps-clip.enable = config.vacu.isGui;
      };
    }
  ];
  vacu.packages = [
    (script "ms" (ms_text false))
    (script "mss" (ms_text true))
    (script "msl" ''
      svl_exact_args $# 1
      host="$1"
      echo 'echo "user:"; screen -ls; echo; echo "root:"; sudo screen -ls' | ssh -T "$host"
    '')
    (script "rmln" ''
      svl_min_args $# 1
      for arg in "$@"; do
        if [[ "$arg" != -* ]] && [[ ! -L "$arg" ]]; then
          svl_die "$arg is not a symlink"
        fi
      done
      rm "$@"
    '')
    (script "altcaps-copy" ''
      declare result
      result="$(altcaps "$@")"
      printf '%s' "$result" | wl-copy
      echo "Copied to clipboard: $result"
    '')
    (script "altcaps-clip" ''
      declare current_clipboard
      # removes a final newline but whatever
      current_clipboard="$(wl-paste)"
      printf '%s' "$current_clipboard" | altcaps | wl-copy
    '')
    (script "nr" ''
      # nix run nixpkgs#<thing> -- <args>
      svl_min_args $# 1
      installable="$1"
      shift
      if [[ $installable != *#* && $installable != *:* ]]; then
        installable="nixpkgs#$installable"
      fi
      nix run "$installable" -- "$@"
    '')
    (script "nb" ''
      # nix build nixpkgs#<thing> <args>
      svl_min_args $# 1
      ${alt_default_installables}
      nix build "''${new_args[@]}"
    '')
    (script "ns" ''
      # nix shell nixpkgs#<thing>
      svl_min_args $# 1
      ${alt_default_installables}
      nix shell "''${new_args[@]}"
    '')
    (script "nixview" ''
      svl_min_args $# 1
      view_cmd="$1"
      shift
      d="$(mktemp -d --suffix=vacu-nixview)"
      l="$d/out"
      nix build --out-link "$l" "$@"
      "$view_cmd" "$l"
      rm -r "$d"
    '')
    (script "nts" ''
      svl_max_args $# 1
      declare tempdir suffix="-vacu-nts"
      if (( $# > 0 )); then
        suffix="''${suffix}-$1"
      fi
      tempdir="$(mktemp -d --suffix="$suffix")"
      (
        declare -i exit_code
        cd -- "$tempdir"
        svl_capture_exit_code_into exit_code "$SHELL"
        echo "temp shell exited with code $exit_code"
      )
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
    '')
    (simple "nixcat" [
      "nixview"
      "cat"
    ])
    (simple "nixless" [
      "nixview"
      "less"
    ])
    (simple "sc" [ systemctl ])
    (simple "scs" [
      systemctl
      "status"
      "--lines=20"
      "--full"
    ])
    (simple "scc" [
      systemctl
      "cat"
    ])
    (simple "scr" [
      systemctl
      "restart"
    ])
    (simple "jc" [
      journalctl
      "--pager-end"
    ])
    (simple "jcu" [
      journalctl
      "--pager-end"
      "-u"
    ])
    (simple "jcf" [
      journalctl
      "-f"
    ])
    (simple "jcfu" [
      journalctl
      "-f"
      "-u"
    ])
    (simple "gs" [
      "git"
      "status"
    ])
    #git lazy commit
    (script "glc" ''
      svl_max_args $# 1
      declare -i do_push=0
      if [[ $# == 1 ]]; then
        if [[ $1 != "push" ]]; then
          svl_die 'first arg must be "push" or not present'
        fi
        do_push=1
      fi
      git add .
      git status
      svl_confirm_or_die --default-yes "commit this?"
      git commit -m stuff
      if (( $do_push )); then
        echo "Pushing in background"
        git push >/dev/null 2>/dev/null &
      fi
    '')
    (simple "glcp" [
      "glc"
      "push"
    ])
    (
      let
        args = [
          "ls"
          "--all" # show everything...
          "--ignore=.." # except for .. (parent directory)
          "--color=auto"
          "--si"
          "--format=long" # aka -l
          "--classify=always"
          "--time-style=iso"
          "--quoting-style=shell-escape"
        ];
      in
      scriptWith {
        name = "vl";
        completeAsAlias = args;
        content = ''
          declare -a files=()
          declare -a opts=()
          while (( $# > 0 )); do
            declare arg="$1"
            shift
            case "$arg" in
              --)
                files+=("$@")
                shift $#
                ;;
              -*)
                opts+=("$arg")
                ;;
              *)
                files+=("$arg")
                ;;
            esac
          done

          declare only_file=""
          if [[ ''${#files[@]} == 1 ]]; then
            only_file="''${files[0]}"
          fi

          # if there's only one arg, and it's a symlink to a directory
          if [[ -n $only_file && -L $only_file && -d $only_file && $only_file != */ ]]; then
            ${lib.escapeShellArgs args} "''${opts[@]}" "$only_file"
            echo
            files=("$only_file/")
          fi
          exec ${lib.escapeShellArgs args} "''${opts[@]}" "''${files[@]}"
        '';
      }
    )
    (script "list-auto-roots" ''
      svl_exact_args $# 0
      shopt -s nullglob
      declare auto_roots="/nix/var/nix/gcroots/auto"
      echo "List of auto nix gcroots:"
      echo
      declare -i system_count=0 other_ignored_count=0
      for fn in "$auto_roots/"*; do
        if ! [[ -L "$fn" ]]; then
          svl_die "fn is not a symlink!?: $fn"
        fi
        declare pointed
        pointed="$(readlink -v -- "$fn")"
        if ! [[ -e "$pointed" ]]; then
          continue
        fi
        case "$pointed" in
          /nix/var/nix/profiles/system-*)
            system_count=$((system_count + 1))
            ;;
          */.cache/nix/flake-registry.json | */dev/nix-stuff/.generated)
            other_ignored_count=$((other_ignored_count + 1))
            ;;
          *)
            printf '%q\n' "$pointed"
            ;;
        esac
      done
      printf "\nand %d system profiles and %d ignored\n" $system_count $other_ignored_count
    '')
  ];
  vacu.shell.functions = {
    nd = ''
      svl_min_args $# 1
      declare -a args=("$@")
      lastarg="''${args[-1]}"
      if [[ "$lastarg" == "-"* ]]; then
        echo "nd: last argument must be the directory" 1>&2
        return 1
      fi
      for arg in "''${args[@]::''${#args[@]}-1}"; do
        if [[ "$arg" != "-"* ]]; then
          echo "nd: last argument must be the directory" 1>&2
          return 1
        fi
      done
      mkdir "''${args[@]}" && cd "''${args[-1]}"
    '';
    nt = ''
      svl_max_args $# 1
      declare -a extraArgs=()
      if (( $# >= 1 )); then
        extraArgs+=(--suffix=-"$1")
      fi
      pushd "$(mktemp -d "''${extraArgs[@]}")"
    '';
  };
  vacu.textChecks."vacu-shell-functions-nd" = ''
    source ${lib.escapeShellArg pkgs.shellvaculib.file}
    function nd() {
      ${config.vacu.shell.functions.nd}
    }

    start=/tmp/test-place
    mkdir -p $start
    cd $start
    nd a
    [[ "$PWD" == "$start/a" ]]
    cd $start
    nd -p b/c
    [[ "$PWD" == "$start/b/c" ]]
  '';
  vacu.textChecks."vacu-shell-functions-nt" = ''
    source ${lib.escapeShellArg pkgs.shellvaculib.file}
    function nt() {
      ${config.vacu.shell.functions.nt}
    }
    start=$PWD
    nt
    [[ "$PWD" != "$start" ]]
    popd
    [[ "$PWD" == "$start" ]]
  '';
}
