{ inputs
, config
, pkgs
, lib
, ...
}:

let
  inherit (inputs) dotfiles;

in {
  imports = [
    "${inputs.self}/home/modules"
    ./modules

    ./profiles/dev.nix
    ./profiles/fish.nix
    ./profiles/helix.nix
  ];

  fonts.fontconfig.enable = true;

  home = {
    username = "bjorn";
    homeDirectory = "/home/${config.home.username}";
    stateVersion = "23.05";

    file = {
      ".xkb/symbols/colemak-bs_cl".source = "${dotfiles}/config/xkbmap/colemak-bs_cl";
      ".xkb/symbols/dvorak-bs_cl".source = "${dotfiles}/config/xkbmap/dvorak-bs_cl";
    };

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
    nix-index = {
      enable = true;
      enableFishIntegration = config.programs.fish.enable;
      enableZshIntegration = config.programs.zsh.enable;
    };
    peaclock =
      let
        originalConfig = builtins.readFile "${inputs.dotfiles}/config/peaclock/binary-clock";
        config = builtins.replaceStrings ["notify-send"] ["${lib.getExe pkgs.libnotify}"] originalConfig;
      in {
        enable = true;
        settings = config;
        enableAlias = true;
      };
  };

  services.gnome-keyring = {
    enable = true;
    components = [ "secrets" ];
  };

  # TODO: Review
  xdg = {
    #enable = true;
    userDirs = {
      createDirectories = true;
      desktop = "\$HOME/Surtabla";
      documents = "\$HOME/Dokumentujo";
      download = "\$HOME/Elsxutujo";
      music = "\$HOME/Muzikujo";
      pictures = "\$HOME/Bildujo";
      publicShare = "\$HOME/Publika";
      templates = "\$HOME/Sxablonujo";
      videos = "\$HOME/Filmetujo";
      extraConfig = {
        XDG_DEVICE_DIR = "\$HOME/Aparatoj";
        XDG_MISC_DIR = "\$HOME/Utilecoj";
      };
    };
  };
}
