{ pkgs, config, lib, nixgram, ... }:
with (import ../../globalConfig.nix);
{
  imports = [
    "${flake.inputs.nixgram}/hmModule.nix"
    "${flake.inputs.redial_proxy}/hmModule.nix"
    ./modules/dlna.nix
    ./modules/firefox/home.nix
    ./modules/dunst.nix
    ./modules/dummy_module.nix
    ./modules/i3.nix
    ./modules/wallpaper.nix
    ../../modules/polybar/home.nix
    ../../modules/spotify/home.nix
    ../../modules/tmux/home.nix
    ../../modules/vscode/home.nix
  ]
  ;

  home.packages = with pkgs; [
   # ------------ pacotes do nixpkgs ---------------
    # minecraft  # custom (excluded)
    usb_tixati custom_rofi # custom
    tdesktop # communication
    obsidian
    vlc youtube-dl # media
    chromium
    file
    fortune
    libnotify
    neofetch
  ] ++ (builtins.attrValues pkgs.webapps);

  home.file.".dotfilerc".text = ''
    #!/usr/bin/env bash
    ${flake.outputs.environmentShell}
  '';

  programs.hello-world.enable = true;

  services.redial_proxy.enable = true;

  programs = {
    # adskipped-spotify.enable = true;
    command-not-found.enable = true;
    jq.enable = true;
    obs-studio = {
      enable = true;
    };
    htop = {
      enable = true;
      settings = {
        hideThreads = true;
        treeView = true;
      };
    };
    tmux.enable = true;
    vscode.enable = true;
  };

  # Git
  programs.git = {
        enable = true;
        userName = username;
        userEmail = email;
  };

  # KDE connect
  services.kdeconnect = {
    enable = true;
    indicator = true;
  };

  # Polybar
  services.polybar.enable = true;
  xsession.windowManager.i3.enable = true;

  # Dconf
  dconf.settings = {
    "org/gnome/desktop/background" = {
      picture-options = "zoom";
      primary-color = "#ffffff";
      secondary-color = "#000000";
    };
    "org/gnome/desktop/input-sources" = 
      let
        tuple = lib.hm.gvariant.mkTuple;
      in 
    {
      current = "uint32 0";
      sources = [(tuple ["xkb" "br"]) (tuple ["xkb" "us"])];
      xkb-options = [ "terminate:ctrl_alt_bksp" ];
    };
    "org/gnome/desktop/interface" = {
      cursor-theme = "Adwaita";
      gtk-im-module = "gtk-im-context-simple";
      gtk-theme = "Adwaita-dark";
    };
    "org/gnome/desktop/peripherals/keyboard" = {
      numlock-state = false;
    };
    "org/gnome/desktop/privacy" = {
      disable-microphone = true;
      report-technical-problems = false;
    };
    "org/gnome/system/location" = {
      enabled = false;
    };
    "org/gnome/desktop/periphereals/touchpad" = {
      tap-to-click = true;
    };
  };

  # nixgram
  services.nixgram = with pkgs; {
    enable = true;
    dotenvFile = rootPath + "/secrets/nixgram.env";
    customCommands = {
      echo = "echo $*";
      wait = ''
        sleep $1
        echo Waited for $1 seconds!
      '';
      speak = ''
        ${espeak}/bin/espeak -v mb/mb-br1 "$*"
      '';
      flow = wrapDotenv "flows.env" ''
      PAYLOAD="
      {
          \"ref\": \"main\"
      }
      "
      curl \
        -X POST \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Authorization: Bearer $GITHUB_TOKEN" \
        "https://api.github.com/repos/lucasew/flows/actions/workflows/2929078/dispatches" \
        -d "$PAYLOAD" || echo "Fail" && echo "Ok"
      '';
      p2k = wrapDotenv "p2k.env" ''
      unset QT_QPA_PLATFORMTHEME
      export AMOUNT=10

      if [ -n "$DEFAULT_AMOUNT" ]; then
          AMOUNT=$DEFAULT_AMOUNT
      fi

      if [ -n "$1" ]; then
          AMOUNT=$1
      fi

      if [ -n "$TESTING" ]; then
          exit 0
      fi
      ${p2k}/bin/p2k -k $KINDLE_EMAIL -c $AMOUNT -t 30 $EXTRA_PARAMS
      '';
      letsgo = ''
        echo "let's gou"
      '';
    };
  };
  services.flameshot.enable = true;

  # wallpaper
  wallpaper = {
    enable = true;
    wallpaperFile = wallpaper;
  };


  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  gtk = {
    enable = true;
    theme.name = "Adwaita-dark";
  };
  qt = {
    enable = true;
    platformTheme = "gtk";
  };
  # home.stateVersion = "20.03";

}
