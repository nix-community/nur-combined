{
  pkgs,
  lib ? pkgs.lib,
}:

rec {
  mkBashCompletion =
    cmd: list:
    let
      first = lib.head list;
      underscored = lib.concatStringsSep "_" list;
    in
    pkgs.writeTextDir "share/bash-completion/completions/${cmd}" ''
      function _complete_shortcommand_${underscored} {
        local __COMPS
        ((COMP_CWORD+=${toString ((lib.length list) - 1)}))
        COMP_WORDS=( ${lib.escapeShellArgs list} "${"$"}{COMP_WORDS[@]:1}" )
        # this is for exotic commands like git
        COMP_LINE="${lib.escapeShellArgs list} ${"$"}{COMP_WORDS[@]:1}"
        # after COMP_LINE update we need to update this as well
        COMP_POINT=${"$"}{#COMP_LINE}
        __load_completion ${first}
        __COMPS="$(complete -p ${first}))"
        # check for completion function
        [[ $__COMPS =~ -F\ (_[-_0-9a-zA-Z]+) ]] && {
          # eval completion function
          ${"$"}{BASH_REMATCH[1]}
        }
        return 0
      }
      complete -F _complete_shortcommand_${underscored} ${cmd}
    '';

  mkShortCommandScript =
    cmd: list: pkgs.writeShellScriptBin cmd ''exec ${lib.escapeShellArgs list} "$@"'';

  mkShortCommand =
    cmd: list:
    pkgs.symlinkJoin {
      name = "shortcommand-${cmd}";
      paths = [
        (mkBashCompletion cmd list)
        (mkShortCommandScript cmd list)
      ];
    };
}
