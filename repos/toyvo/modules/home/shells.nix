{
  config,
  lib,
  ...
}:
let
  cfg = config.nixcfg.shells;
in
{
  options.nixcfg.shells.enable = lib.mkEnableOption "shell tools";

  config = lib.mkIf cfg.enable {
    home.sessionVariables._ZO_ECHO = 1;
    programs = {
      starship = {
        enable = true;
        settings = {
          right_format = "$time";
          time.disabled = false;
          git_status = {
            ahead = "⇡$count";
            behind = "⇣$count";
            diverged = "⇡$ahead_count⇣$behind_count";
            stashed = "📦$count";
          };
        };
      };
      zoxide.enable = true;
      bat.enable = true;
      eza.enable = true;
      zsh.enable = true;
      bash.enable = true;
      fish.enable = true;
      ion.enable = true;
      nushell.enable = true;
      powershell.enable = true;
    };
  };
}
