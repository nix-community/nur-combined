# These are the things that might in a simpler time go in ~/.bashrc as aliases. But they're not aliases, cuz aliases are bad
{
  pkgs,
  lib,
  config,
  vacupkglib,
  ...
}:
let
  inherit (vacupkglib) script;
  simple =
    name: args:
    let
      binContents = ''
        #!${lib.getExe pkgs.bash}
        exec ${lib.escapeShellArgs args} "$@"'';
      funcContents = ''
        declare aliasName=${lib.escapeShellArg name}
        declare -a replacementWords=(${lib.escapeShellArgs args})
        declare replacementStr
        declare oldIFS="$IFS"
        IFS=' '
        replacementStr="''${replacementWords[*]}"
        IFS="$oldIFS"
        COMP_LINE="''${COMP_LINE/#$aliasName/$replacementStr}"
        COMP_POINT=$(( COMP_POINT + ''${#replacementStr} - ''${#aliasName} ))
        COMP_CWORD=$(( COMP_CWORD + ''${#replacementWords[@]} - 1 ))
        COMP_WORDS=("''${replacementWords[@]}" "''${COMP_WORDS[@]:1}")
        _comp_command_offset 0
      '';
    in
    pkgs.runCommandLocal "vacu-notalias-simple-${name}"
      {
        pname = name;
        meta.mainProgram = name;
      }
      ''
        mkdir -p "$out"/bin
        printf '%s' ${lib.escapeShellArg binContents} > "$out"/bin/${name}
        chmod a+x "$out"/bin/${name}
        out_base="$(basename -- "$out")"
        LC_ALL=C
        completion_function_name="_completion_''${out_base//[^a-zA-Z0-9_]/_}"
        completion_file="$out"/share/bash-completion/completions/${name}
        mkdir -p "$(dirname -- "$completion_file")"
        printf '%s() {\n%s\n}\n' "$completion_function_name" ${lib.escapeShellArg funcContents} > "$completion_file"
        printf 'complete -F %s %s\n' "$completion_function_name" ${lib.escapeShellArg name} >> "$completion_file"
      '';
  ms_text = with_sudo: ''
    svl_minmax_args $# 1 2
    host="$1"
    session_name="''${2:-main}"
    set -x
    mosh -- "$host" ${lib.optionalString with_sudo "sudo"} screen -RdS "$session_name"
  '';
  systemctl = "${pkgs.systemd}/bin/systemctl";
  journalctl = "${pkgs.systemd}/bin/journalctl";
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
      result="$(altcaps "$@")"
      printf '%s' "$result" | wl-copy
      echo "Copied to clipboard: $result"
    '')
    (script "altcaps-clip" ''
      # removes a final newline but whatever
      current_clipboard="$(wl-paste)"
      printf '%s' "$current_clipboard" | altcaps | wl-copy
    '')
    (script "nr" ''
      # nix run nixpkgs#<thing> -- <args>
      svl_min_args $# 1
      installable="$1"
      shift
      if [[ $installable != *'#'* ]] && [[ $installable != *':'* ]]; then
        installable="nixpkgs#$installable"
      fi
      nix run "$installable" -- "$@"
    '')
    (script "nb" ''
      # nix build nixpkgs#<thing> <args>
      svl_min_args $# 1
      installable="$1"
      shift
      if [[ "$installable" != *'#'* ]]; then
        installable="nixpkgs#$installable"
      fi
      nix build "$installable" "$@"
    '')
    (script "ns" ''
      # nix shell nixpkgs#<thing>
      svl_min_args $# 1
      new_args=( )
      for arg in "$@"; do
        if [[ "$arg" != *'#'* ]] && [[ "$arg" != -* ]]; then
          arg="nixpkgs#$arg"
        fi
        new_args+=("$arg")
      done
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
    (simple "ll" [ "ls" "-a" "-l" ])
    (script "list-auto-roots" ''
      declare auto_roots="/nix/var/nix/gcroots/auto"
      svl_exact_args $# 0
      echo "List of auto nix gcroots:"
      echo
      declare -i system_count=0 other_ignored_count=0
      for fn in "$auto_roots/"*; do
        if ! [[ -L "$fn" ]]; then
          die "fn is not a symlink!?: $fn"
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
            printf '%s\n' "$pointed"
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
