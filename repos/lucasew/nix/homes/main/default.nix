{ global, pkgs, lib, self, ... }:
let
  inherit (lib.hm.gvariant) mkTuple;
  inherit (pkgs.custom) colors;
in {

  imports = [
    ../base/default.nix
    ./dlna.nix
    ./helix
    ./espanso.nix
    ./dconf.nix
    ./borderless-browser.nix
    ./theme
    ./discord.nix
    ./qutebrowser.nix
    ./mopidy.nix
  ];
  services.mopidy.enable = true;

  programs.helix.enable = true;
  # services.espanso.enable = true;
  programs.man.enable = true;

  programs.qutebrowser.enable = true;


  home = {
    homeDirectory = /home/lucasew;
    inherit (global) username;
  };

  home.packages = with pkgs; [
    anki
    gum
    calibre # a dependency is broken
    chromium
    regex101
    custom.tixati
    custom.pidgin
    # (custom.neovim.override { inherit colors; })
    # (custom.emacs.override { inherit colors; })
    # custom.firefox # now I am using chromium
    # custom.vscode.programming
    cached-nix-shell
    devenv
    dotenv
    jless # json viewer
    rustdesk # remote desktop for many systems
    gscan2pdf
    feh
    fortune
    graphviz
    github-cli
    gimp
    gnome.evince
    libnotify
    libreoffice
    mendeley
    ncdu
    # nix-option
    nix-prefetch-scripts
    nix-output-monitor
    obsidian
    pkg
    rclone
    ripgrep
    fd
    remmina
    sqlite
    sshpass

    # communication
    tdesktop
    # nbr.telegram-desktop-bin

    # media
    vlc
    stremio
    moonlight-qt
    nbr.wine-apps._7zip
    xxd
    pavucontrol # controle de volume
    pytorrentsearch
    # LSPs
    nil
    python3Packages.python-lsp-server
    (pkgs.writeShellScriptBin "e" ''
      if [ ! -v EDITOR ]; then
        export EDITOR=hx
      fi
      "$EDITOR" "$@"
    '')
  ] ;

  # programs.hello-world.enable = true;

  services.redial_proxy.enable = true;

  programs = {
    # adskipped-spotify.enable = true;
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
  };

  gtk = {
    enable = true;
  };
  qt = {
    enable = true;
    platformTheme = "gtk";
  };

  programs.terminator = {
    # enable = true;
    config = {
      global_config.borderless = true;
    };
  };
  programs.bash.enable = true;
}
