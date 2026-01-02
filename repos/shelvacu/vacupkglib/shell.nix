{ lib, pkgs, ... }:
let
  completionStuff =
    { name, args }:
    assert builtins.isString name;
    assert builtins.isList args;
    rec {
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
      installLines = ''
        out_base="$(basename -- "$out")"
        LC_ALL=C
        completion_function_name="_completion_''${out_base//[^a-zA-Z0-9_]/_}"
        completion_file="$out"/share/bash-completion/completions/${name}
        mkdir -p "$(dirname -- "$completion_file")"
        printf '%s() {\n%s\n}\n' "$completion_function_name" ${lib.escapeShellArg funcContents} > "$completion_file"
        printf 'complete -F %s %s\n' "$completion_function_name" ${lib.escapeShellArg name} >> "$completion_file"
      '';
    };
in
rec {
  scriptWith =
    {
      name,
      content,
      completeAsAlias ? null,
      prelude ? true,
    }:
    let
      completion =
        if completeAsAlias != null then
          (completionStuff {
            inherit name;
            args = completeAsAlias;
          })
        else
          { installLines = ""; };
    in
    (pkgs.writers.makeScriptWriter
      {
        interpreter = lib.getExe pkgs.bashInteractive;
        check = lib.escapeShellArgs [
          (lib.getExe pkgs.shellcheck)
          "--norc"
          "--severity=info"
          "--exclude=SC2016"
          pkgs.shellvaculib.file
        ];
      }
      "/bin/${name}"
      ''
        ${lib.optionalString prelude ''
          source ${lib.escapeShellArg pkgs.shellvaculib.file} || exit 1
          # This decrements SHLVL by one to offset the shell that launched this script, which I don't want counted
          if [[ -n ''${SHLVL-} ]]; then
            declare -i shell_level_int="$SHLVL"
            if (( shell_level_int <= 1 )); then
              unset SHLVL
            else
              SHLVL=$((shell_level_int - 1))
            fi
            unset shell_level_int
          fi
        ''}
        ${content}
      ''
    ).overrideAttrs
      {
        passthru = { inherit completion; };
        postInstall = completion.installLines;
      };

  script = name: content: scriptWith { inherit name content; };

  aliasScript =
    name: args:
    let
      binContents = ''
        #!${lib.getExe pkgs.bash}
        exec ${lib.escapeShellArgs args} "$@"'';
      completion = completionStuff { inherit name args; };
    in
    pkgs.runCommandLocal "vacu-notalias-simple-${name}"
      {
        pname = name;
        meta.mainProgram = name;
        passthru = { inherit completion; };
      }
      ''
        mkdir -p "$out"/bin
        printf '%s' ${lib.escapeShellArg binContents} > "$out"/bin/${name}
        chmod a+x "$out"/bin/${name}
        ${completion.installLines}
      '';
}
