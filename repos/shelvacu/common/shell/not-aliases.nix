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
    declare -a remote_cmd=(
      ${lib.optionalString with_sudo "sudo"} tmux new-session -A -s "$session_name"
    )
    declare ssh_config
    ssh_config="$(ssh -G -- "$host")"
    declare -a cmd=(exec)
    if (printf '%s' "$ssh_config" | grep -q "^proxyjump "); then
      echo "INFO: proxyjump detected, no mosh" >&2
      cmd+=(ssh -t)
    else
      cmd+=(mosh)
    fi
    cmd+=(-- "$host" "''${remote_cmd[@]}")
      
    set -x
    "''${cmd[@]}"
  '';
  systemctl = "${pkgs.systemd}/bin/systemctl";
  journalctl = "${pkgs.systemd}/bin/journalctl";

  altcapsPkg = pkgs.altcaps;
  altcapsBin = lib.getExe altcapsPkg;

  wl-clipboardPkg = pkgs.wl-clipboard;
  wl-copy = lib.getExe' wl-clipboardPkg "wl-copy";
  wl-paste = lib.getExe' wl-clipboardPkg "wl-paste";

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
      echo 'echo "user:"; tmux list-sessions; echo; echo "root:"; sudo tmux list-sessions' | ssh -T -- "$host"
    '')
    (script "rmln" ''
      svl_min_args $# 1
      declare passed_dashdash="false"
      for arg in "$@"; do
        if [[ $passed_dashdash == "true" ]] || [[ $arg != -* ]]; then
          if [[ ! -L $arg ]]; then
            svl_die "$arg is not a symlink"
          fi
        elif [[ $arg == "--" ]]; then
          passed_dashdash="true"
        fi
      done
      rm "$@"
    '')
    (script "rmempty" ''
      svl_min_args $# 1
      declare passed_dashdash="false"
      for arg in "$@"; do
        if [[ $passed_dashdash == "true" ]] || [[ $arg != -* ]]; then
          if [[ ! -e $arg ]]; then
            svl_die "does not exist: $arg"
          fi
          if [[ ! -f $arg ]]; then
            svl_die "not a regular file: $arg"
          fi
          if [[ -s $arg ]]; then
            svl_die "not empty: $arg"
          fi
        elif [[ $arg == "--" ]]; then
          passed_dashdash="true"
        fi
      done
      rm "$@"
    '')
    (script "altcaps-copy" ''
      declare result
      result="$(${altcapsBin} "$@")"
      printf '%s' "$result" | ${wl-copy}
      printf "Copied to clipboard: %q\n" "$result"
    '')
    (script "altcaps-clip" ''
      declare current_clipboard
      # removes a final newline but whatever
      current_clipboard="$(${wl-paste})"
      printf '%s' "$current_clipboard" | ${altcapsBin} | ${wl-copy}
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
    (script "nix-locate-bin" ''
      svl_exact_args $# 1
      exec ${lib.getExe' pkgs.nix-index "nix-locate"} --whole-name --at-root "/bin/$1"
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
    (simple "nvimro" [
      "nvim"
      "-R"
    ])
    (simple "vcp" [
      "cp"
      "--update=none-fail"
    ])
    (simple "vmv" [
      "mv"
      "--update=none-fail"
    ])
    #git lazy commit
    (script "glc" ''
      grep_nofail() {
        if grep "$@"; then
          return 0
        else
          declare -i exitcode=$?
          if [[ $exitcode == 1 ]]; then
            # no matches found, which is fine
            return 0
          fi
          return $exitcode
        fi
      }
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
      declare status_info status_info_noheaders
      status_info="$(git status -b --porcelain=v2)"
      status_info_noheaders="$(grep_nofail -v '^#' <<<"$status_info")"
      if [[ $status_info_noheaders == "" ]]; then
        : # Nothing to commit
      else
        svl_confirm_or_die --default-yes "commit this?"
        git commit -m stuff
      fi
      if (( $do_push )); then
        declare upstream upstream_branch upstream_remote
        upstream="$(git status -b --porcelain=v2 | grep_nofail --only-matching '(?<=^# branch.upstream ).*' -P)"
        if [[ -z $upstream ]]; then
          svl_die "no upstream set, cannot push"
        fi
        upstream_branch="''${upstream#*/}"
        upstream_remote="''${upstream%%/*}"
        git fetch "$upstream_remote" "$upstream_branch"
        if git merge-base HEAD "$upstream"; then
          echo "Pushing in background"
          git push >/dev/null 2>/dev/null &
        else
          declare -i exitcode=$?
          if [[ $exitcode != 1 ]]; then
            svl_die "git merge-base failed with exit code $exitcode"
          fi
          echo "Cannot push: not a fast-forward"
        fi
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
    (simple "steam-minigames" [
      "xdg-open"
      "steam://open/minigameslist"
    ])
    (simple "batn" [
      # bat with no line numbers or diff info, so copy+paste across multiple lines works
      "bat"
      "--style=-numbers,-changes"
    ])
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
