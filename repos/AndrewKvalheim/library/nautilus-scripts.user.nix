{ config, lib, pkgs, ... }:

let
  inherit (lib) concatMapAttrs getExe' mkOption;
  inherit (lib.strings) sanitizeDerivationName;
  inherit (lib.types) attrsOf nullOr str submodule;
  inherit (pkgs) uutils-findutils writeShellScript;

  mkNautilusScript = name: content:
    writeShellScript "nautilus-script-${sanitizeDerivationName name}" ''
      set -Eeuxo pipefail
      paths_lines="$(echo -n "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS" | sed /^$/d)"
      readarray -t paths < <(echo -n "$paths_lines")
      ${content}
    '';
in
{
  options.nautilusScripts = mkOption {
    default = { };
    type = attrsOf (submodule {
      options = {
        each = mkOption { default = null; type = nullOr str; };
        xargs = mkOption { default = null; type = nullOr str; };
      };
    });
  };

  config = {
    xdg.dataFile = concatMapAttrs
      (name: { each ? null, xargs ? null }: {
        "nautilus/scripts/${name}".source = mkNautilusScript name (if each != null then ''
          for path in "''${paths[@]}"; do
            ${each}
          done
        '' else ''
          echo -n "$paths_lines" | tr '\n' '\0' | ${getExe' uutils-findutils "xargs"} -0 ${xargs}
        '');
      })
      config.nautilusScripts;
  };
}
