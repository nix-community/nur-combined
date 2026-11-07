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
    kate # ships KWrite too; it is a symlink-style frontend of Kate now
    elisa
    okular # replaced by pdfcraft-bin (productivity.nix)
  ];

  # plasma6 defaults this to true (services/desktop-managers/plasma6.nix),
  # pulling kmail/kontact/merkuro/akonadi as direct systemPackages — the
  # excludePackages list cannot remove them because they enter elsewhere.
  programs.kde-pim.enable = false;

  environment.systemPackages = with pkgs; [
    kde-rounded-corners
  ];

  home-manager.sharedModules = [
    ({
      pkgs,
      lib,
      ...
    }: {
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
      # kwriteconfig6 is referenced by its full store path because the
      # home-manager-ac systemd service runs with a minimal PATH that does
      # not include /run/current-system/sw/bin.
      home.activation.kdeDefaults = let
        kwriteconfig6 = "${pkgs.kdePackages.kconfig}/bin/kwriteconfig6";
      in
        lib.hm.dag.entryAfter ["writeBoundary"] ''
          ${kwriteconfig6} --file "$HOME/.config/kdeglobals" --group General --key TerminalApplication kitty
          ${kwriteconfig6} --file "$HOME/.config/dolphinrc" --group General --key ShellExecuter kitty
          ${kwriteconfig6} --file "$HOME/.config/ksmserverrc" --group General --key loginMode default
          ${kwriteconfig6} --file "$HOME/.config/ksmserverrc" --group General --key confirmLogout false
          # Work around ksplashqml crash loops that can bounce users back to SDDM.
          ${kwriteconfig6} --file "$HOME/.config/ksplashrc" --group KSplash --key Engine none
          ${kwriteconfig6} --file "$HOME/.config/kwinrc" --group Compositing --key OpenGLIsUnsafe false
          ${kwriteconfig6} --file "$HOME/.config/kwinrc" --group Wayland --key EnableEarlyOutput false
          ${kwriteconfig6} --file "$HOME/.config/kxkbrc" --group Layout --key LayoutList us,tr
          ${kwriteconfig6} --file "$HOME/.config/kxkbrc" --group Layout --key Use --type bool true
          # Baloo's content extractor reached 6 GB on source trees and was OOM-killed.
          ${kwriteconfig6} --file "$HOME/.config/baloofilerc" --group General --key "exclude folders" "$HOME/Code/,$HOME/Android/"
        '';
    })
  ];
}
