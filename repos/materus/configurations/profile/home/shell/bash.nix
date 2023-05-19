{ config, pkgs, lib, materusFlake, materusPkgs, ... }:
let 
cfg = config.materus.profile.bash;
in
{
    options.materus.profile.bash.enable = materusPkgs.lib.mkBoolOpt config.materus.profile.enableTerminal "Enable materus bash config";


    config = lib.mkIf cfg.enable {

      programs.bash = {
        enable = lib.mkDefault true;
        enableCompletion = lib.mkDefault true;
        enableVteIntegration = lib.mkDefault true;
        historyControl = lib.mkDefault ["erasedups" "ignorespace"];
        shellOptions = lib.mkDefault [ "autocd" "checkwinsize" "cmdhist" "expand_aliases" "extglob" "globstar" "checkjobs" "nocaseglob" ];
      };
    };

}
