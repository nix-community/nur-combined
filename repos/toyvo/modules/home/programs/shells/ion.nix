{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.programs.ion;
in
{
  options.programs.ion.initExtraEnd = lib.mkOption {
    type = lib.types.lines;
    default = "";
    description = "Ion init lines to put at the end of the file";
  };

  config = lib.mkIf cfg.enable {
    programs.ion.initExtra = ''
      # Variables
      ${lib.concatStringsSep "\n" (
        lib.mapAttrsToList (
          name: value: "export ${name} = \"${toString value}\""
        ) config.home.sessionVariables
      )}

      # PATH
      let nix_paths = [${lib.concatStringsSep " " config.home.sessionPath}]
      let paths_to_export = []
      for path in @split($PATH ':')
        if test -d $path
          match $path
            case @nix_paths;
            case _; let paths_to_export = [ @paths_to_export $path ]
          end
        end
      end
      for path in @nix_paths
        if test -d $path
          let paths_to_export = [ @paths_to_export $path ]
        end
      end
      export PATH = $join(paths_to_export ":")

      # InitExtraEnd
      ${cfg.initExtraEnd}
    '';
  };
}
