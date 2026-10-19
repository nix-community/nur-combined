{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.dots.terminal.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable the terminal dotfiles module.";
  };

  config = lib.mkIf config.dots.terminal.enable {
    programs = {
      kitty = {
        enable = false;
        shellIntegration = {
          enableZshIntegration = true;
        };
        settings = {
          macos_titlebar_color = "#2E3440";
          window_padding_width = 0;
          window_margin_width = 0;
          adjust_line_height = "120%";
          font_family = "Comic Code Ligatures";
          font_size = "16.0";
        };
        enableGitIntegration = true;
        extraConfig = ''

          map cmd+h hide_macos_app
          map cmd+m minimize_macos_window
          map cmd+q quit
          map kitty_mod+p>y kitten hints --type hyperlink
        '';
      };
      # ghostty = {
      #   enable = true;
      #   # package = inputs.ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default;
      #   package = pkgs.ghostty-bin;
      # installVimSyntax = true;
      # installBatSyntax = true;
      # enableZshIntegration = true;
      # enableFishIntegration = true;
      # enableBashIntegration = true;
      # };
      ghostty = {
        enable = true;
        package = pkgs.ghostty-bin; # macos be funky
        settings = {
          font-size = 16;
          font-family = "Comic Code Ligatures";
          adjust-cell-height = "50%";
          font-thicken = true;
          font-thicken-strength = 120;
          keybind = "global:cmd+grave_accent=toggle_quick_terminal";

        };
        installVimSyntax = true;
        installBatSyntax = true;
        enableZshIntegration = true;
        enableFishIntegration = true;
        enableBashIntegration = true;
      };
    };
    home.packages = [ pkgs.ghostty-bin ];
  };
}
