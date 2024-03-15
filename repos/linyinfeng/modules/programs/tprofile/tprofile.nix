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
    systemd.tmpfiles.rules = [ "d /run/tprofile 777 root root - -" ];
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
