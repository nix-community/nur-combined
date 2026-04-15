{ config, lib, ... }:
let
  cfg = config.my.home.pager;
in
{
  options.my.home.pager = with lib; {
    enable = my.mkDisableOption "pager configuration";
  };


  config = lib.mkIf cfg.enable {
    programs.less = {
      enable = true;

      config = ''
        #command
        # Quit without clearing the screen on `Q`
        Q toggle-option -!^Predraw-on-quit\nq

        #line-edit
        # readline-style command editing
        ^p up
        ^n down
        ^b left
        ^f right
        ^a home
        ^e end
        \eb word-left
        \ef word-right
        ^w word-backspace
        \ed word-delete
        # Simulate delete to start/end of line by repeating word-wise actions
        ^u word-backspace ${lib.strings.replicate 100 "^w"}
        ^k word-delete ${lib.strings.replicate 100 "\\ed"}
      '';
    };

    home.sessionVariables = {
      # My default pager
      PAGER = "less";
      # Set `LESS` in the environment so it overrides git's pager (and others)
      LESS =
        let
          options = {
            # Always use the alternate screen (so that it is cleared on exit)
            "+no-init" = true;
            # Write text top-down, rather than from the bottom
            clear-screen = true;
            # Interpret (some) escape sequences
            RAW-CONTROL-CHARS = true;
            # Use colored text in search and UI
            use-color = true;
          };
        in
        lib.concatStringsSep " " (lib.cli.toCommandLineGNU { } options);
    };
  };
}
