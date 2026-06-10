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

    sops.templates."shell-secrets.env" = lib.mkIf config.nixcfg.users.toyvo.enable {
      content = ''
        OPENCODE_API_KEY=${config.sops.placeholder.opencode_api_key}
      '';
    };
    programs.bash.initExtra = lib.mkIf config.nixcfg.users.toyvo.enable ''
      source ${config.sops.templates."shell-secrets.env".path}
      export OPENCODE_API_KEY
    '';
    programs.zsh.initExtra = lib.mkIf config.nixcfg.users.toyvo.enable ''
      source ${config.sops.templates."shell-secrets.env".path}
      export OPENCODE_API_KEY
    '';
    programs.fish.interactiveShellInit = lib.mkIf config.nixcfg.users.toyvo.enable ''
      sourceenv ${config.sops.templates."shell-secrets.env".path} > /dev/null 2>&1
    '';
  };
}
