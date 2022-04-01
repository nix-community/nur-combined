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
      mate-settings-daemon-wrapped
      mate-themes
    ];

    mate-session-manager = super.mate.mate-session-manager.overrideAttrs(_: rec {
      patches = [
        ./mate-session-only-x11.patch
      ];
    });

    mate-settings-daemon = super.mate.mate-settings-daemon.overrideAttrs(_: rec {
      patches = [
        ./mate-settings-daemon-only-x11.patch
      ];
    });

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
