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

    mate-control-center = super.mate.mate-control-center.overrideAttrs(oldAttrs: rec {
      preFixup = oldAttrs.preFixup + ''
        gappsWrapperArgs+=(
          # Works only if after gtk3 schemas in the wrapper for some reason
          --prefix XDG_DATA_DIRS : "${super.glib.getSchemaDataDirPath super.mate.caja}"
        )
      '';
    });

    mate-panel = super.mate.mate-panel.overrideAttrs(oldAttrs: rec {
      preFixup = ''
        gappsWrapperArgs+=(
          # Works only if after gtk3 schemas in the wrapper for some reason
          --prefix XDG_DATA_DIRS : "${super.glib.getSchemaDataDirPath super.mate.marco}"
        )
      '';
    });

    mate-settings-daemon-wrapped = super.stdenv.mkDerivation {
      pname = "${super.mate.mate-settings-daemon.pname}-wrapped";
      version = super.mate.mate-settings-daemon.version;
      nativeBuildInputs = with super; [ wrapGAppsHook ];
      buildInputs = with super; [ glib mate.mate-control-center ];
      dontWrapGApps = true;
      dontUnpack = true;
      installPhase = ''
        mkdir -p $out/etc/xdg/autostart
        cp ${super.mate.mate-settings-daemon}/etc/xdg/autostart/mate-settings-daemon.desktop $out/etc/xdg/autostart
      '';
      postFixup = ''
        mkdir -p $out/libexec
        makeWrapper ${super.mate.mate-settings-daemon}/libexec/mate-settings-daemon $out/libexec/mate-settings-daemon \
          "''${gappsWrapperArgs[@]}"
        substituteInPlace $out/etc/xdg/autostart/mate-settings-daemon.desktop \
          --replace "${super.mate.mate-settings-daemon}/libexec/mate-settings-daemon" "$out/libexec/mate-settings-daemon"
      '';
      meta = super.mate.mate-settings-daemon.meta // { priority = -10; };
    };

    caja-extensions = super.mate.caja-extensions.overrideAttrs(oldAttrs: rec {
      patches = [
        (super.substituteAll {
          src = ./hardcode-gsettings.patch;
          CAJA_GSETTINGS_PATH = super.glib.getSchemaPath super.mate.caja;
          TERM_GSETTINGS_PATH = super.glib.getSchemaPath super.mate.mate-terminal;
        })
      ];

      postPatch = ''
        substituteInPlace open-terminal/caja-open-terminal.c --subst-var-by \
          GSETTINGS_PATH ${super.glib.makeSchemaPath "$out" "${oldAttrs.pname}-${oldAttrs.version}"}
        substituteInPlace sendto/caja-sendto-command.c --subst-var-by \
          GSETTINGS_PATH ${super.glib.makeSchemaPath "$out" "${oldAttrs.pname}-${oldAttrs.version}"}
        substituteInPlace wallpaper/caja-wallpaper-extension.c --subst-var-by \
          GSETTINGS_PATH ${super.glib.makeSchemaPath "$out" "${oldAttrs.pname}-${oldAttrs.version}"}
      '';
    });
  };
}
