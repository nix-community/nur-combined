{
  config,
  lib,
  pkgs,
  vaculib,
  vacupkglib,
  vacuModuleType,
  ...
}:
let
  inherit (lib) mkOption types;
  cfg = config.vacu.shell;
  writeShellFunction =
    name: text:
    pkgs.writeTextFile {
      inherit name;
      executable = false;
      destination = "/share/vacufuncs/${name}";
      text = ''
        ${text}
      '';
      checkPhase = ''
        ${pkgs.stdenv.shellDryRun} "$target"
      '';
    };
  functionPackages = lib.mapAttrsToList writeShellFunction cfg.functions;
  vacuInitFile = pkgs.writeText "vacu.shell.interactiveLines.sh" cfg.interactiveLines;
  wrappedBashPkg = vacupkglib.makeWrapper {
    original = pkgs.bash;
    new = "vacuinit-bash";
    prepend_flags = [
      "--init-file"
      vacuInitFile
    ];
  };
  wrappedBash = wrappedBashPkg;
in
{
  imports = [ ]
  ++ vaculib.directoryGrabberList ./.
  ++ lib.optional (vacuModuleType == "nixos") {
    environment.pathsToLink = [ "/share/vacufuncs" ];
    programs.bash = {
      interactiveShellInit = config.vacu.shell.interactiveLines;
      promptInit = lib.mkForce "";
    };
    environment.shellAliases = {
      # disable the defaults
      ll = null;
      l = null;
      ls = null;
    };
  }
  ++ lib.optional (vacuModuleType == "nix-on-droid") {
    vacu.shell.functionsDir = "${config.user.home}/.nix-profile/share/vacufuncs";
    environment.etc = {
      bashrc.text = config.vacu.shell.interactiveLines;
      profile.text = config.vacu.shell.interactiveLines;
    };
  };
  options.vacu.shell = {
    functionsDir = mkOption {
      type = types.path;
      default = "/run/current-system/sw/share/vacufuncs";
    };
    interactiveLines = mkOption {
      type = types.lines;
      readOnly = true;
    };
    wrappedBash = mkOption { readOnly = true; };
    idempotentShellLines = mkOption {
      type = types.lines;
      default = "";
    };
    color = mkOption {
      type = types.enum (builtins.attrNames vaculib.shellColors);
      default = "white";
    };
    functions = mkOption { type = types.attrsOf types.str; };
  };
  config.vacu = {
    shell.interactiveLines = ''
      if [[ $- == *i* ]]; then
        SHELLVACULIB_COMPAT=1 source ${lib.escapeShellArg pkgs.shellvaculib.file}
        if [[ -f ${cfg.functionsDir}/vacureload ]]; then
          function __vacushell_load() { eval "$(<${cfg.functionsDir}/vacureload)"; }
          __vacushell_load
          unset __vacushell_load
        fi
      fi
    '';
    shell.wrappedBash = wrappedBash;
    shell.idempotentShellLines = lib.mkBefore ''
      PROMPT_COMMAND=()
      PS0=""
      alias ls='ls --color=auto'
    '';
    shell.functions = {
      "vacureload" = ''
        declare -gA vacuShellFunctionsLoaded
        if ! [[ -f ${cfg.functionsDir}/vacureload ]]; then
          echo "vacureload: I think that's my cue to leave (${cfg.functionsDir}/vacureload not found, assuming vacureload-less config has been loaded and unloading myself)" 1>&2
          for funcname in "''${!vacuShellFunctionsLoaded[@]}"; do
            unset -f $funcname
          done
          return
        fi
        for funcname in "''${!vacuShellFunctionsLoaded[@]}"; do
          if ! [[ -f ${cfg.functionsDir}/$funcname ]]; then
            unset -f $funcname
          fi
        done
        for fullPath in ${cfg.functionsDir}/*; do
          local funcname="$(basename "$fullPath")"
          local followedPath="$(readlink -f "$fullPath")"
          if [[ "''${vacuShellFunctionsLoaded[$funcname]-}" != "$followedPath" ]]; then
            unset -f $funcname
            eval "function ''${funcname}() { if [[ -f '$fullPath' ]]; then eval "'"$'"(<'$fullPath')"'"'"; else echo '$funcname is no longer there, kindly removing myself.' 1>&2; unset $funcname; return 1; fi }"
            vacuShellFunctionsLoaded[$funcname]=$followedPath
          fi
          unset followedPath
          unset funcname
        done
        __run_idempotents
        # your idempotent shell lines are idempotent, right?
        __run_idempotents
      '';
      "__run_idempotents" = cfg.idempotentShellLines;
      vhich = ''
        if [[ $# != 1 ]]; then
          echo "expected exactly one arg" 1>&2
          return 1
        fi
        declare query="$1"
        declare quote='`'"$query'"
        declare kind="$(type -t -- "$query")"
        if [[ "$kind" == "" ]]; then
          echo "could not find any command $quote" 1>&2
          return 1
        fi
        echo "$quote is a $kind"
        case "$kind" in
          "alias")
            alias "$query"
            return 0
            ;;
          "keyword")
            echo "See https://www.gnu.org/software/bash/manual/html_node/Reserved-Word-Index.html"
            return 0
            ;;
          "function")
            if [[ -v vacuShellFunctionsLoaded["$query"] ]]; then
              echo "$quote is a vacufunc"
              path="''${vacuShellFunctionsLoaded[$query]}"
              # continue to below
            else
              declare -f "$query"
              return 0
            fi
            ;;
          "builtin")
            echo "Docs: https://www.gnu.org/software/bash/manual/html_node/Bash-Builtins.html#index-$query"
            return 0
            ;;
          "file")
            path="$(type -p "$query")"
            # continue to below
            ;;
          *)
            echo 'ERR: unexpected return from `type -t`: '"$kind" 1>&2
            return 1
        esac
        echo "path:"
        while [[ -L "$path" ]]; do
          declare dest="$(readlink -- "$path")"
          echo "  $path is a symlink to $dest"
          if [[ "$dest" != /* ]]; then
            dest="$(dirname -- "$path")/$dest"
          fi
          path="$dest"
        done
        echo "  $path"
        if ! [[ -e "$path" ]]; then
          echo "$path does not exist!"
          return 1
        fi
        if ! [[ -x "$path" ]]; then
          echo "$path is not executable!"
          return 1
        fi
        canon="$(readlink -f -- "$path")"
        if [[ "$path" != "$canon" ]]; then
          echo "  $path canonicalizes to $canon"
          path="$canon"
        fi
        magic_parse="$(file --brief --mime -- "$path")"
        echo "magic: $magic_parse"
        case "$magic_parse" in
          'text/x-shellscript;'* | 'text/plain;'*)
            echo "initial contents:"
            echo
            head --lines=10 "$path" | head --bytes=2000
            echo "..."
            ;;
        esac
      '';
    };
    packages = functionPackages;
  };
}
