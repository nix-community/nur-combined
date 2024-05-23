{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.programs.carapace;
in

{
  options.abszero.programs.carapace = {
    enable = mkEnableOption "carapace";
    enableNushellIntegration = mkEnableOption "custom Nushell integration with some fixes" // {
      default = true;
    };
  };

  config.programs = mkIf cfg.enable {
    carapace = {
      enable = true;
      # Fish integration overrides native completions which we want to use with nushell
      enableFishIntegration = mkIf cfg.enableNushellIntegration false;
      # Use custom integration
      enableNushellIntegration = mkIf cfg.enableNushellIntegration false;
    };

    # https://www.nushell.sh/cookbook/external_completers.html
    nushell.extraConfig = mkIf cfg.enableNushellIntegration ''
      let prev_completer = $env.config?.completions?.external?.completer? | default echo
      let next_completer = {|spans: list<string>|
        let completion = carapace $spans.0 nushell ...$spans
        if $completion != "" {
          let parsed_completion = $completion | from json
          if ($parsed_completion | where value == $"($spans | last)ERR" | is-empty) {
            return $parsed_completion
          }
        }
        do $prev_completer $spans
      }
      $env.config = ($env.config?
      | default {}
      | merge { completions: { external: { completer: $next_completer } } })
    '';
  };
}
