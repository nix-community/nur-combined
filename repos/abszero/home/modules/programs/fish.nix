{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkMerge
    mkBefore
    mkAfter
    pipe
    ;
  cfg = config.abszero.programs.fish;
in

{
  options.abszero.programs.fish = {
    enable = mkEnableOption "managing fish";
    enableNushellIntegration = mkEnableOption "using fish only as an external completer for nushell";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ any-nix-shell ];

    programs = {
      fish = {
        enable = true;
        interactiveShellInit = ''
          set fish_greeting ""
          any-nix-shell fish --info-right | source
        '';
        functions = {
          qcomm = "qfile (which $argv)";
          fetchhash = "nix flake prefetch --json $argv | jq -r .hash";
        };
      };

      foot.settings.main.shell = mkIf (!cfg.enableNushellIntegration) "fish";
      ghostty.settings.command = mkIf (!cfg.enableNushellIntegration) "fish";

      # https://www.nushell.sh/cookbook/external_completers.html
      nushell.extraConfig =
        pipe
          [
            # Lowermost fallback
            (mkBefore ''
              let fish_completer = {|spans: list<string>|
                fish -ic $'complete "--do-complete=($spans | str join " ")"'
                | $"value(char tab)description(char newline)" + $in
                | from tsv --flexible --no-infer
              }
              $env.config = ($env.config?
              | default {}
              | merge { completions: { external: { completer: $fish_completer } } })
            '')

            # Specific commands that work better with fish completion
            (mkAfter ''
              let prev_completer = $env.config?.completions?.external?.completer? | default echo
              let next_completer = {|spans: list<string>|
                if $spans.0 in [ nix ] {
                  do $fish_completer $spans
                } else {
                  do $prev_completer $spans
                }
              }
              $env.config = ($env.config?
              | default {}
              | merge { completions: { external: { completer: $next_completer } } })
            '')
          ]
          [
            mkMerge
            (c: mkIf cfg.enableNushellIntegration c)
          ];
    };
  };
}
