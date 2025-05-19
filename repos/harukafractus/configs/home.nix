{ username }:
{ pkgs, config, lib, ... }: {
  home = {
    username = username;
    homeDirectory = if pkgs.stdenv.isDarwin then
      "/Users/${username}"
    else
      "/home/${username}";
    stateVersion = "24.11";
    shellAliases = { gc = "sudo nix-collect-garbage -d; nix-collect-garbage -d"; };
  };

  home.file.".nanorc" = {
    enable = true;
    text = "include ${pkgs.nano}/share/nano/*.nanorc";
  };

  programs.git = {
    enable = true;
    ignores = [
      "*.DS_Store"
      "*__pycache__/"
      "node_modules"
    ];

    extraConfig = {
      init = { defaultBranch = "main"; };
      user = {
        email = "106440141+harukafractus@users.noreply.github.com";
        name = "harukafractus";
        signingkey = "~/.ssh/id_rsa.pub";
      };
      gpg = { format = "ssh"; };
      commit = { gpgSign = true; };
    };
  };

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    noto-fonts
    source-han-sans
    source-han-mono
    source-han-serif
    source-han-code-jp
    meslo-lgs-nf
    fortune-kind
    cowsay
    eza
    bat
    imagemagick
    python3Full
    htop
    wget
    unar
    # GUI APPS
    sqlitebrowser
    librewolf
    qbittorrent
    telegram-desktop
    vscodium
  ] ++ (if pkgs.stdenv.isLinux then [
    # too be added..
  ] else [
    libreoffice-bin
    whisky
    lunarfyi
    iina
    utm
  ]);

  programs.zsh = {
    enable = true;
    autocd = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    initContent = ''
      zstyle ':completion:*' menu select
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
      if [[ $TERM = "xterm-256color" ]]; then
          source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
          source ~/.p10k.zsh
      fi
      export LESSHISTFILE=- 
      fortune-kind | cowsay -f koala
    '';

    shellAliases = {
      cat = "bat --paging=never";
      less = "bat";
      ls = "eza -lh --octal-permissions --no-permissions --group  -F";
    };
  };

  targets.darwin.defaults = {
    NSGlobalDomain = { 
      _NS_4445425547 = true; # Enable Debug Menu
      AppleShowAllExtensions = true; # Show file extensions
      "com.apple.mouse.tapBehavior" = 1;  # Enable trackpad tap to click
    };

    # Disable .DS_Store Writing
    "com.apple.desktopservices" = {
      DSDontWriteNetworkStores = true;
      DSDontWriteUSBStores = true;
    };

    "com.apple.finder" = {
      _FXSortFoldersFirst = true; # Show Folder on top;
      FXPreferredViewStyle = "Nlsv"; # default to list view
      AppleShowAllFiles = true;  # Show hidden files
      QuitMenuItem = true;  # Quit Find by CMD+Q
      FXEnableExtensionChangeWarning = false; # Changing file extension warning
      ShowPathbar = true;   # Show bottom path bar
    };

    # Show battery percentage
    "com.apple.controlcenter.plist" = { BatteryShowPercentage = true; };
  }; 

  dconf.settings = if pkgs.stdenv.isLinux then {
    "org/gnome/desktop/peripherals/touchpad" = {
      "natural-scroll" = false;
      "tap-to-click" = true;
    };

    "org/gnome/desktop/interface" = {
      enable-hot-corners = false;
      show-battery-percentage = true;
    };

    "org/gnome/nautilus/preferences" = { default-folder-viewer = "list-view"; };
    "org/gnome/nautilus/list-view" = { default-zoom-level = "small"; };

    "org/gnome/settings-daemon/peripherals/touchscreen" = {
      orientation-lock = true;
    };
    "org/gnome/desktop/datetime" = { automatic-timezone = true; };
    "org/gnome/system/location" = { enabled = true; };
    "org/gnome/mutter" = {
      edge-tiling = true;
      experimental-features = [ "scale-monitor-framebuffer" ];
    };

    "org/gnome/desktop/app-folders" = {
      folder-children = [ "LibreOffice" "Utilities" ];
    };
    
    "org/gnome/desktop/app-folders/folders/LibreOffice" = {
      name = "LibreOffice";
      apps = [
        "org.libreoffice.LibreOffice.desktop"
        "org.libreoffice.LibreOffice.base.desktop"
        "org.libreoffice.LibreOffice.calc.desktop"
        "org.libreoffice.LibreOffice.draw.desktop"
        "org.libreoffice.LibreOffice.impress.desktop"
        "startcenter.desktop"
        "org.libreoffice.LibreOffice.math.desktop"
        "org.libreoffice.LibreOffice.writer.desktop"
        "math.desktop"
        "writer.desktop"
        "impress.desktop"
        "draw.desktop"
        "calc.desktop"
        "base.desktop"
      ];
    };

    "org/gnome/shell" = { app-picker-layout = [ ]; };
  } else
    { };
}
