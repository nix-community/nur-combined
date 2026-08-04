{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

{
  programs.starship = {
    enable = true;
    enableFishIntegration = config.programs.fish.enable;
    enableZshIntegration = config.programs.zsh.enable;
    settings = lib.mkMerge [
      (lib.mkIf config.programs.jujutsu.enable {
        format = "\${custom.jj} $all";
        custom.jj = {
          command = "prompt";
          format = "$output";
          ignore_timeout = true;
          shell = [
            "${lib.getExe pkgs.starship-jj}"
            "--ignore-working-copy"
            "starship"
          ];
          use_stdin = false;
          when = true;
        };
      })
    ];
  };
  xdg.configFile."starship-jj/starship-jj.toml".source =
    "${inputs.dotfiles}/config/starship-jj/starship-jj.toml";
}
