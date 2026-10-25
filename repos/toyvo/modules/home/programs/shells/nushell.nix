{ config, lib, ... }:
let
  cfg = config.programs.nushell;
in
{
  config = lib.mkIf cfg.enable {
    programs.nushell = {
      shellAliases = config.home.shellAliases;
      envFile.text = ''
        $env.config = {
          show_banner: false
          edit_mode: vi
        }
        ${lib.concatStringsSep "\n" (
          lib.mapAttrsToList (
            name: value: "$env.${name} = \"${toString value}\""
          ) config.home.sessionVariables
        )}
        let nix_paths = [${lib.concatStringsSep " " config.home.sessionPath}] | where ($it | path exists)
        let pre_paths = $env.PATH | split row ":" | where ($it | path exists) | where ($it not-in $nix_paths)
        let export_paths = [$pre_paths $nix_paths] | flatten
        $env.PATH = $export_paths
      '';
    };
  };
}
