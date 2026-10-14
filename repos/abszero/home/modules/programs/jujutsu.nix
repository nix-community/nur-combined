{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf mkDefault;
  inherit (lib.abszero.attrsets) findValue;
  cfg = config.abszero.programs.jujutsu;

  primaryEmail = findValue (_: v: v.primary) config.accounts.email.accounts;
in

{
  options.abszero.programs.jujutsu.enable = mkEnableOption "simple and powerful VCS";

  config = mkIf cfg.enable {
    abszero.programs = {
      git.enable = true;
      oyui = {
        enable = true;
        enableJujutsuIntegration = true;
        config = ''
          pub fn config() {
            keybind("c", global::confirm);

            // TODO: fix when there's a way to disable builtin keybinding
            on_mode("file", || {
              keybind("Enter", || {
                view::file::staging::toggle();
                view::file::nav::next_hunk();
              });
              keybind("n", || {
                view::file::staging::toggle_line();
                view::file::cursor::down(1);
              });
            });

            on_mode("tree", || {
              keybind("Enter", || {
                view::tree::staging::toggle_selected();
                view::tree::cursor::down(1);
              });
            });
          }
        '';
      };
    };

    programs = {
      jujutsu = {
        enable = true;
        settings = {
          user = {
            name = mkDefault primaryEmail.realName;
            email = mkDefault primaryEmail.address;
          };
          signing = {
            behavior = "own";
            backend = mkIf config.programs.gpg.enable "gpg";
          };
          ui.default-command = "log";
        };
      };

      difftastic.jujutsu.enable = true;

      jjui.enable = true;

      mergiraf.enableJujutsuIntegration = true;
    };
  };
}
