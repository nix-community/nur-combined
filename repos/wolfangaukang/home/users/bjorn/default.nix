{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (inputs) dotfiles;
  inherit (pkgs.stdenv) hostPlatform;

in
{
  imports = [
    "${inputs.self}/home/modules/peaclock.nix"

    ./modules

    ./profiles/dev.nix
    ./profiles/fish.nix
    ./profiles/gpodder.nix
    ./profiles/helix.nix
  ];

  fonts.fontconfig.enable = true;

  home = {
    username = "bjorn";
    homeDirectory =
      let
        prefix = if hostPlatform.isDarwin then "Users" else "home";
      in
      "/${prefix}/${config.home.username}";
    file =
      if hostPlatform.isLinux then
        builtins.listToAttrs (
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
        )
      else
        { };

    packages =
      with pkgs;
      [
        # CLI
        bc
        htop
        p7zip
        tree
        shellcheck

        # GUI but with CLI tools
        keepassxc

        # Fonts
        arkpandora_ttf
      ]
      ++ (lib.optionals hostPlatform.isLinux [ calibre ]); # https://github.com/NixOS/nixpkgs/commit/36351ac94e9c6608bb95f6946f2ec01dee45f65b
  };

  programs = {
    atuin = {
      enable = true;
      enableFishIntegration = config.programs.fish.enable;
      enableZshIntegration = config.programs.zsh.enable;
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
    enable = hostPlatform.isLinux;
    components = [ "secrets" ];
  };

  xdg = {
    enable = hostPlatform.isLinux;
    terminal-exec = {
      enable = true;
      settings.default =
        [ ]
        ++ lib.optionals config.programs.kitty.enable [ "kitty.desktop" ]
        ++ lib.optionals config.programs.alacritty.enable [ "alacritty.desktop" ];
    };
    userDirs = {
      enable = true;
      extraConfig.MISC = "${config.home.homeDirectory}/Utilecoj";
      setSessionVariables = false; # NOTE: Default behavior in 26.05
    }
    // builtins.mapAttrs (name: value: "${config.home.homeDirectory}/${value}") {
      documents = "Dokumentujo";
      download = "Elsxutujo";
      music = "Muzikujo";
      pictures = "Bildujo";
    };
  };
}
