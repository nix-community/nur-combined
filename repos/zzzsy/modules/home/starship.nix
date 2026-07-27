{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkForce
    mkIf
    mkOption
    types
    ;
  cfg = config.my.programs.starship;
in
{
  options = {
    my.programs.starship = {
      enableFishAsyncPrompt = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enableFishAsyncPrompt {
    programs.starship.enableFishIntegration = mkForce false;

    programs.fish.interactiveShellInit = ''
      if test "$TERM" != dumb
          ${lib.getExe config.programs.starship.package} init fish | source
          source ${./async_prompt.fish}
      end
    '';
  };
}
