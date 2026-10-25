{ lib, ... }:

let
  inherit (lib) types mkOption singleton;

  mainModule = { pkgs, ... }: {
    abszero = {
      profiles.driftwm.enable = true;
      themes = {
        base = {
          pointerCursor.enable = true;
          fastfetch.enable = true;
          ghostty.enable = true;
          nushell.enable = true;
          starship.enable = true;
        };
        colloid.gtk.enable = true;
        noctalia = {
          driftwm.enable = true;
          fcitx5.enable = true;
          gtk.enable = true;
          noctalia.enable = true;
        };
      };
    };

    home.pointerCursor = {
      name = "aris-cursors";
      package = pkgs.aris-cursors;
    };

    wayland.windowManager.driftwm.settings.outputs = singleton {
      name = "DP-4";
      mode = "3840x2160@120";
      scale = 2;
      # variable-refresh-rate = true; # TODO: enable when supported
    };

    programs.opencode.web.enable = true;
  };

  configModule = {
    modules = singleton {
      config.programs.helix.languages.language-server.ai.config.models = {
        "qwen3.8-27b".chat_endpoint = "http://nixos-fwdesktop:11434/v1/chat/completions";
        "gemma-4-12b-instruct".chat_endpoint = "http://nixos-fwdesktop:11434/v1/chat/completions";
      };
    };
  };
in

{
  options.abszero.homeConfigurations = mkOption {
    type = with types; attrsOf (submodule configModule);
  };

  config.abszero.homeConfigurations."weathercold@nixos-fwdesktop" = {
    system = "x86_64-linux";
    modules = [
      mainModule
    ];
  };
}
