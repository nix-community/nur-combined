{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf mkOrder;
  cfg = config.abszero.programs.nushell;
in

{
  options.abszero.programs.nushell.enable = mkEnableOption "a new type of shell";

  config.programs = mkIf cfg.enable {
    foot.settings.main.shell = "nu";
    ghostty.settings.command = "nu";

    nushell = {
      enable = true;

      shellAliases = {
        "..." = "cd ../..";
        "...." = "cd ../../..";
        ani = "ani-cli";
        c = "clear";
        cat = "bat";
        f = "fastfetch";
        lns = "ln -s";
      };

      # https://www.nushell.sh/book/configuration.html
      # https://github.com/amtoine/nushell/blob/main/crates/nu-utils/src/sample_config/default_config.nu
      configFile.text = ''
        $env.config = {
          use_kitty_protocol: true
          show_banner: false
        }
      '';

      # Order of overrides of completer:
      # Fish <-- Carapace <-- Zoxide & Fish <-- Expand Alias
      extraConfig = mkOrder 2000 ''
        let prev_completer = $env.config?.completions?.external?.completer? | default echo
        let next_completer = {|spans: list<string>|
          let expansion = scope aliases
          | where name == $spans.0
          | get -i 0.expansion
          | default $spans.0
          | split row " "

          do $prev_completer ($spans | skip 1 | prepend $expansion)
        }
        $env.config = ($env.config?
        | default {}
        | merge { completions: { external: { completer: $next_completer } } })
      '';
    };
  };
}
