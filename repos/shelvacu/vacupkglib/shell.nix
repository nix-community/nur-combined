{ lib, pkgs, ... }:
{
  script =
    name: content:
    pkgs.writers.makeScriptWriter
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
        source ${lib.escapeShellArg pkgs.shellvaculib.file} || exit 1
        # This decrements SHLVL by one to offset the shell that launched this script, which I don't want counted
        if [[ -n ''${SHLVL-} ]]; then
          declare -i shell_level_int="$SHLVL"
          if (( shell_level_int <= 1 )); then
            unset SHLVL
          else
            SHLVL=$((shell_level_int - 1))
          fi
        fi
        ${content}
      '';
}
