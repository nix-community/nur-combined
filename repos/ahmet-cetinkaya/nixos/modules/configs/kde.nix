{lib, ...}: {
  # Configure Kitty as the default terminal for Dolphin "Open Terminal Here" action
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
    # Disable automatic app restore on crash
    "kcrashrc".text = ''
      [General]
      # Disable automatic restart of crashed applications
      AutoRestart=false
    '';
  };

  # Update only specific KDE keys without overwriting full rc files.
  # This preserves Konsave-managed theme settings in kdeglobals/kwinrc.
  home.activation.kdeDefaults = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if command -v kwriteconfig6 >/dev/null 2>&1; then
      kwriteconfig6 --file "$HOME/.config/kdeglobals" --group General --key TerminalApplication kitty
      kwriteconfig6 --file "$HOME/.config/dolphinrc" --group General --key ShellExecuter kitty
      kwriteconfig6 --file "$HOME/.config/ksmserverrc" --group General --key loginMode default
      kwriteconfig6 --file "$HOME/.config/ksmserverrc" --group General --key confirmLogout false
      # Work around ksplashqml crash loops that can bounce users back to SDDM.
      kwriteconfig6 --file "$HOME/.config/ksplashrc" --group KSplash --key Engine none
      kwriteconfig6 --file "$HOME/.config/kwinrc" --group Compositing --key OpenGLIsUnsafe false
      kwriteconfig6 --file "$HOME/.config/kwinrc" --group Wayland --key EnableEarlyOutput false
    fi
  '';
}
