{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.kitty;

  configModule = types.submodule {
    options = {
      editor = mkOption {
        type = types.str;
        default = ".";
        example = "vim";
        description = ''
          The console editor to use when editing the kitty config file or
          similar tasks.  A value of . means to use the environment variables
          VISUAL and EDITOR in that order. Note that this environment variable
          has to be set not just in your shell startup scripts but system-wide,
          otherwise kitty will not see it.
        '';
      };
      modifier = mkOption {
        type = types.str;
        default = "ctrl+shift";
        description = "The modifier for all default shortcuts.";
      };
      scrollbackLines = mkOption {
        type = types.int;
        default = 2000;
        example = -1;
        description = ''
          Number of lines of history to keep in memory for scrolling
          back. Memory is allocated on demand. Negative numbers are
          (effectively) infinite scrollback. Note that using very large
          scrollback is not recommended as it can slow down resizing of the
          terminal and also use large amounts of RAM.
        '';
      };
      shell = mkOption {
        type = types.str;
        default = ".";
        example = "fish";
        description = ''
          The shell program to execute. The default value of . means to use
          whatever shell is set as the default shell for the current user. Note
          that on macOS if you change this, you might need to add --login to
          ensure that the shell starts in interactive mode and reads its startup
          rc files.
        '';
      };
      term = mkOption {
        type = types.str;
        default = "xterm-kitty";
        example = "xterm";
        description = "The value of the TERM environment variable to set.";
      };
    };
  };

  # NOTE: https://raw.githubusercontent.com/dexpota/kitty-themes/master/themes/Wombat.conf
  configFile = pkgs.writeText "kitty.conf" (optionalString (cfg.config != null) ''
    scrollback_lines ${toString cfg.config.scrollbackLines}
    editor ${cfg.config.editor}
    shell ${cfg.config.shell}
    term ${cfg.config.term}
    background            #171717
    foreground            #ded9ce
    cursor                #bbbbbb
    selection_background  #453a39
    color0                #000000
    color8                #313131
    color1                #ff605a
    color9                #f58b7f
    color2                #b1e869
    color10               #dcf88f
    color3                #ead89c
    color11               #eee5b2
    color4                #5da9f6
    color12               #a5c7ff
    color5                #e86aff
    color13               #ddaaff
    color6                #82fff6
    color14               #b6fff9
    color7                #ded9ce
    color15               #fefffe
    selection_foreground #171717
    kitty_mod ${cfg.config.modifier}
    map kitty_mod+enter new_window_with_cwd
    map kitty_mod+k combine : clear_terminal scrollback active : send_text normal \x0c
  '' + (optionalString (hasSuffix "darwin" builtins.currentSystem) ''
    macos_option_as_alt yes
  ''));
in
{

  options.programs.kitty = {
    enable = mkEnableOption "kitty - the fast, featureful, GPU based terminal emulator";
    package = mkOption {
      type = types.package;
      default = pkgs.kitty;
      defaultText = literalExample "pkgs.kitty";
      description = "The kitty package to use.";
    };
    config = mkOption {
      type = types.nullOr configModule;
      default = { };
      description = "kitty configuration options.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    xdg.configFile."kitty/kitty.conf" = {
      source = configFile;
    };
  };

}
