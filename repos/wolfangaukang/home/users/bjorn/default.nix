{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (inputs) dotfiles;

in
{
  imports = [
    ./modules

    ./profiles/dev.nix
    ./profiles/fish.nix
    ./profiles/gpodder.nix
    ./profiles/helix.nix
  ];

  fonts.fontconfig.enable = true;

  home = {
    username = "bjorn";
    homeDirectory = "/home/${config.home.username}";
    stateVersion = "23.05";

    file = builtins.listToAttrs (
      builtins.map
        (layout: {
          name = ".xkb/symbols/${layout}";
          value = {
            source = "${dotfiles}/config/xkbmap/${layout}";
          };
        })
        [
          "colemak-bs_cl"
          "dvorak-bs_cl"
        ]
    );

    packages = with pkgs; [
      # CLI
      bc
      htop
      p7zip
      tree
      shellcheck

      # GUI but with CLI tools
      calibre
      keepassxc

      # Fonts
      arkpandora_ttf
    ];
  };

  programs = {
    atuin = {
      enable = true;
      enableFishIntegration = true;
      settings.style = "auto";
      flags = [ "--disable-up-arrow" ];
    };
    broot = {
      enable = true;
      enableFishIntegration = config.programs.fish.enable;
    };
    nix-index = {
      enable = true;
      enableFishIntegration = config.programs.fish.enable;
      enableZshIntegration = config.programs.zsh.enable;
    };
    peaclock =
      let
        originalConfig = builtins.readFile "${inputs.dotfiles}/config/peaclock/binary-clock";
        config =
          builtins.replaceStrings [ "notify-send" ] [ "${lib.getExe pkgs.libnotify}" ]
            originalConfig;
      in
      {
        enable = true;
        settings = config;
        enableAlias = true;
      };
    ssh.enableDefaultConfig = false;
  };

  services.gnome-keyring = {
    enable = true;
    components = [ "secrets" ];
  };

  xdg = {
    enable = true;
    terminal-exec = {
      enable = true;
      settings.default =
        [ ]
        ++ lib.optionals config.programs.kitty.enable [ "kitty.desktop" ]
        ++ lib.optionals config.programs.alacritty.enable [ "alacritty.desktop" ];
    };
    userDirs = {
      enable = true;
      extraConfig.XDG_MISC_DIR = "${config.home.homeDirectory}/Utilecoj";
    }
    // builtins.mapAttrs (name: value: "${config.home.homeDirectory}/${value}") {
      documents = "Dokumentujo";
      download = "Elsxutujo";
      music = "Muzikujo";
      pictures = "Bildujo";
    };
  };
}
