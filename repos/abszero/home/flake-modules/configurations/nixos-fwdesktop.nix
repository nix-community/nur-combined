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
  };

  configModule = {
    modules = singleton {
      config.programs.helix.languages.language-server.ai.config.models = {
        "qwen3.8-flash-next".chat_endpoint = "http://nixos-fwdesktop.ts.net:11434/v1/chat/completions";
        "qwen3.8-flash-next-instruct".chat_endpoint =
          "http://nixos-fwdesktop.ts.net:11434/v1/chat/completions";
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
