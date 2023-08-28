(
  final: prev: {
    waybar = prev.waybar.overrideAttrs (o: {
      postInstall = ''
        mkdir -p $out/share/dbus-1/services
        cat <<END > $out/share/dbus-1/services/org.kde.StatusNotifierWatcher.service
        [D-BUS Service]
        Name=org.kde.StatusNotifierWatcher
        Exec=/usr/bin/waybar
        # comment SystemdService to start waybar directly
        SystemdService=waybar.service
        END
      '';
    });
  }
)
