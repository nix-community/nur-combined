{ config, pkgs, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf mkOrder;
  cfg = config.abszero.programs.nushell;
in

{
  options.abszero.programs.nushell.enable = mkEnableOption "a new type of shell";

  config.programs.nushell = mkIf cfg.enable {
    enable = true;
    shellAliases = {
      "..." = "cd ../..";
      "...." = "cd ../../..";
      ani = "ani-cli";
      c = "clear";
      cat = "bat";
      lns = "ln -s";
      nf = "neofetch";
      zz = "z -";
    };

    # https://www.nushell.sh/book/configuration.html
    # https://github.com/amtoine/nushell/blob/main/crates/nu-utils/src/sample_config/default_config.nu
    configFile.text = ''
      # TODO: Use catppuccin when an official module is available
      use "${pkgs.nu_scripts-git}/share/nu_scripts/themes/nu-themes/atelier-sulphurpool-light.nu"

      $env.config = {
        shell_integration: true
        show_banner: false
        table: {
          mode: light
          # header_on_separator: true
        }
        color_config: (atelier-sulphurpool-light)
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
}
