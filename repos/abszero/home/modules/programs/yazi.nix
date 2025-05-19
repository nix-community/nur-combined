{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.abszero.programs.yazi;
in

{
  options.abszero.programs.yazi.enable = mkEnableOption "blazing fast terminal file manager";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ ouch ];

    programs.yazi = {
      enable = true;
      shellWrapperName = "y";

      plugins = with pkgs.yaziPlugins; {
        inherit git ouch sudo;
      };

      settings = {
        manager = {
          show_hidden = true;
          sort_by = "natural";
          sort_translit = true; # Transliterate filenames for sorting
          linemode = "size";
          image_delay = 0; # Send image to terminal immediately

          prepend_keymap = [
            {
              on = [
                "l"
                "a"
              ];
              run = "link";
              desc = "Abs link";
            }
            {
              on = [
                "l"
                "r"
              ];
              run = "link --relative";
              desc = "Rel link";
            }
            {
              on = [
                "l"
                "h"
              ];
              run = "hardlink";
              desc = "Hard link";
            }
            {
              on = [
                "L"
                "a"
              ];
              run = "link --force";
              desc = "Abs link";
            }
            {
              on = [
                "L"
                "r"
              ];
              run = "link --relative --force";
              desc = "Rel link";
            }
            {
              on = [
                "L"
                "h"
              ];
              run = "hardlink --force";
              desc = "Hard link";
            }

            {
              on = [
                "R"
                "a"
              ];
              run = "plugin sudo -- create";
              desc = "sudo create";
            }
            {
              on = [
                "R"
                "r"
              ];
              run = "plugin sudo -- rename";
              desc = "sudo rename";
            }
            {
              on = [
                "R"
                "d"
              ];
              run = "plugin sudo -- remove";
              desc = "sudo trash";
            }
            {
              on = [
                "R"
                "D"
              ];
              run = "plugin sudo -- remove --permanently";
              desc = "sudo delete";
            }
            {
              on = [
                "R"
                "p"
              ];
              run = "plugin sudo -- paste";
              desc = "sudo paste";
            }
            {
              on = [
                "R"
                "P"
              ];
              run = "plugin sudo -- paste --force";
              desc = "sudo paste with overwrite";
            }
            {
              on = [
                "R"
                "l"
                "a"
              ];
              run = "plugin sudo -- link";
              desc = "sudo abs link";
            }
            {
              on = [
                "R"
                "l"
                "r"
              ];
              run = "plugin sudo -- link --relative";
              desc = "sudo rel link";
            }
            {
              on = [
                "R"
                "l"
                "h"
              ];
              run = "plugin sudo -- hardlink";
              desc = "sudo hard link";
            }
            {
              on = [
                "R"
                "L"
                "a"
              ];
              run = "plugin sudo -- link --force";
              desc = "sudo abs link with overwrite";
            }
            {
              on = [
                "R"
                "L"
                "r"
              ];
              run = "plugin sudo -- link --relative --force";
              desc = "sudo rel link with overwrite";
            }
            {
              on = [
                "R"
                "L"
                "h"
              ];
              run = "plugin sudo -- hardlink --force";
              desc = "sudo hard link with overwrite";
            }
            {
              on = [ "C" ];
              run = "plugin ouch";
              desc = "Compress with ouch";
            }
          ];
        };

        plugin = {
          prepend_fetchers = [
            {
              id = "git";
              name = "*";
              run = "git";
            }
            {
              id = "git";
              name = "*/";
              run = "git";
            }
          ];

          prepend_previewers = [
            {
              mime = "application/*zip";
              run = "ouch";
            }
            {
              mime = "application/x-tar";
              run = "ouch";
            }
            {
              mime = "application/x-bzip2";
              run = "ouch";
            }
            {
              mime = "application/x-7z-compressed";
              run = "ouch";
            }
            {
              mime = "application/x-rar";
              run = "ouch";
            }
            {
              mime = "application/x-xz";
              run = "ouch";
            }
            {
              mime = "application/xz";
              run = "ouch";
            }
          ];
        };
      };

      initLua = ''
        require("git"):setup()
      '';
    };
  };
}
