self: super: {
  mate = super.mate // {
    basePackages = with self.mate; [
      caja
      libmatekbd
      libmatemixer
      libmateweather
      marco
      mate-common
      mate-control-center
      mate-desktop
      mate-icon-theme
      mate-menus
      mate-notification-daemon
      mate-panel
      mate-polkit
      mate-session-manager
      mate-settings-daemon
      mate-themes
    ];

    mate-panel = super.mate.mate-panel.overrideAttrs(oldAttrs: rec {
      buildInputs = oldAttrs.buildInputs ++ (with super; [
        wayland gtk-layer-shell
      ]);
    
      configureFlags = [
        "--with-in-process-applets=all"
      ];
    });
  };
}
