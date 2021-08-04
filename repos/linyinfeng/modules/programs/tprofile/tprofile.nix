{ config, lib, ... }:

let
  cfg = config.programs.tprofile;
in
{
  options.programs.tprofile = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Wheather to enable tprofile.
      '';
    };
  };

  config = lib.mkIf (cfg.enable) {
    system.activationScripts.tprofile = lib.stringAfter [ "users" "groups" ]
      ''
        echo "setting up /run/tprofile..."
        mkdir --parents --mode=777 /run/tprofile
      '';
    programs.bash.interactiveShellInit = ''
      source ${./tprofile.bash};
    '';
    programs.zsh.interactiveShellInit = ''
      source ${./tprofile.bash};
    '';
    programs.fish.interactiveShellInit = ''
      source ${./tprofile.fish};
    '';
  };
}
