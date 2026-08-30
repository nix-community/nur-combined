{pkgs, ...}: {
  imports = [../apps/utilities/kitty.nix];

  services = {
    xserver = {
      enable = true;
      excludePackages = [pkgs.xterm];
      xkb = {
        layout = "us";
        variant = "";
      };
    };
    displayManager.sddm.enable = true;
    desktopManager.plasma6.enable = true;
  };

  console.keyMap = "trq";

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    konsole
  ];

  environment.systemPackages = with pkgs; [
    kde-rounded-corners
  ];

  home-manager.sharedModules = [
    ({lib, ...}: {
      xdg.configFile = {
        "kservices6/OpenTerminalHere.desktop".text = ''
          [Desktop Entry]
          Type=Service
          ServiceTypes=KonqPopupMenu/Plugin,inode/directory,inode/directory/desktop
          Actions=openTerminalHere

          [Desktop Action openTerminalHere]
          Name=Open Terminal Here
          Icon=utilities-terminal
          Exec=kitty --directory="%f"
        '';
        "kcrashrc".text = ''
          [General]
          AutoRestart=false
        '';
      };

      # Preserve Konsave-managed theme settings by updating only specific KDE keys.
      home.activation.kdeDefaults = lib.hm.dag.entryAfter ["writeBoundary"] ''
        kwriteconfig6 --file "$HOME/.config/kdeglobals" --group General --key TerminalApplication kitty
        kwriteconfig6 --file "$HOME/.config/dolphinrc" --group General --key ShellExecuter kitty
        kwriteconfig6 --file "$HOME/.config/ksmserverrc" --group General --key loginMode default
        kwriteconfig6 --file "$HOME/.config/ksmserverrc" --group General --key confirmLogout false
        # Work around ksplashqml crash loops that can bounce users back to SDDM.
        kwriteconfig6 --file "$HOME/.config/ksplashrc" --group KSplash --key Engine none
        kwriteconfig6 --file "$HOME/.config/kwinrc" --group Compositing --key OpenGLIsUnsafe false
        kwriteconfig6 --file "$HOME/.config/kwinrc" --group Wayland --key EnableEarlyOutput false
        kwriteconfig6 --file "$HOME/.config/kxkbrc" --group Layout --key LayoutList us,tr
        kwriteconfig6 --file "$HOME/.config/kxkbrc" --group Layout --key Use --type bool true
      '';
    })
  ];
}
