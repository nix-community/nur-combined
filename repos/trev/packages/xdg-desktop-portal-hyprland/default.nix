{
  libei,
  libxkbcommon,
  xdg-desktop-portal-hyprland,
}:
xdg-desktop-portal-hyprland.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [
    # remotedesktop: revive portal implementation
    # https://github.com/hyprwm/xdg-desktop-portal-hyprland/pull/428
    ./428.diff

    # keyboard fixes for #428 (keymap passed to EIS, xkb-derived modifiers)
    # https://github.com/hyprwm/xdg-desktop-portal-hyprland/pull/428#issuecomment-5982011340
    ./428-keyboard.diff
  ];

  buildInputs = (old.buildInputs or [ ]) ++ [
    libei
    libxkbcommon
  ];

  # version follows nixpkgs
  passthru = removeAttrs old.passthru [ "updateScript" ];

  meta = old.meta // {
    description = "xdg-desktop-portal backend for Hyprland, with RemoteDesktop support";
  };
})
