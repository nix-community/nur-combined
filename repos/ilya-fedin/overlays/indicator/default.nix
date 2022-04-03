self: super: {
  mate = super.mate // {
    extraPackages = with self.mate; [
      atril
      caja-extensions
      engrampa
      eom
      mate-applets
      mate-backgrounds
      mate-calc
      mate-indicator-applet
      mate-media
      mate-netbook
      mate-power-manager
      mate-screensaver
      mate-sensors-applet
      mate-system-monitor
      mate-terminal
      mate-user-guide
      # mate-user-share
      mate-utils
      mozo
      pluma
    ];

    mate-indicator-applet = super.mate.mate-indicator-applet.overrideAttrs(oldAttrs: {
      buildInputs = oldAttrs.buildInputs ++ (with self; [ ayatana-ido libayatana-indicator-gtk3 ]);
      postPatch = ''
        substituteInPlace src/applet-main.c \
          --replace '/usr' '/run/current-system/sw'
      '';

      configureFlags = [ "--with-ayatana-indicators" ];
    });
  };

  libayatana-indicator-gtk3 = super.libayatana-indicator-gtk3.overrideAttrs(oldAttrs: {
    postPatch = ''
      substituteInPlace libayatana-indicator/ayatana-indicator3-0.4.pc.in.in \
        --replace 'indicatordir=@libdir@' 'indicatordir=/run/current-system/sw/lib'
    '';
  });
}
