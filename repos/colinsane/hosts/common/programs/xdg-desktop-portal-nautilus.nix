{ pkgs, ... }:
{
  sane.programs.xdg-desktop-portal-nautilus = {
    packageUnwrapped = pkgs.rmDbusServices (pkgs.nautilus.overrideAttrs (upstream: {
      preConfigure = (upstream.preConfigure or "") + ''
        cp data/icons/hicolor/scalable/apps/org.gnome.Nautilus.svg data/icons/hicolor/scalable/apps/org.gnome.NautilusPortal.svg
      '';

      postInstall = (upstream.postInstall or "") + ''
        mkdir -p $out/share/xdg-desktop-portal/portals
        cat > $out/share/xdg-desktop-portal/portals/nautilus.portal <<EOF
        [portal]
        DBusName=org.gnome.NautilusPortal
        Interfaces=org.freedesktop.impl.portal.FileChooser
        EOF
      '';

      # define a "profile", which changes the app id/dbus name so that we don't conflict with any other
      # instances of Nautilus that happen to be running on the system
      mesonFlags = (upstream.mesonFlags or []) ++ [
        "-Dprofile=Portal"
      ];
    }));

    sandbox.whitelistDbus = [ "user" ];  # to receive requests from xdg-desktop-portal
    sandbox.whitelistDri = true;  #< else it's laggy on moby
    sandbox.whitelistWayland = true;

    sandbox.extraHomePaths = [
      # grant access to pretty much everything, except for secret keys.
      "/"
      ".persist/ephemeral"
      ".persist/plaintext"
      "Pictures/Photos"
      "Pictures/Screenshots"
      "Pictures/albums"
      "Pictures/cat"
      "Pictures/from"
      "Videos/local"
      "archive"
      "knowledge"
      "nixos"
      "records"
      "tmp"
    ];
    sandbox.extraPaths = [
      "/boot"
      "/mnt/desko"
      "/mnt/lappy"
      "/mnt/moby"
      "/mnt/servo"
      # "nix"
      "/run/media"  # for mounted devices
      "/tmp"
      "/var"
    ];

    services.xdg-desktop-portal-nautilus = {
      description = "xdg-desktop-portal-nautilus backend (provides file chooser for xdg-desktop-portal)";
      dependencyOf = [ "xdg-desktop-portal" ];

      # NAUTILUS_PERSIST, else --gapplication-service means nautilus exits after 10s of inactivity
      command = "env NAUTILUS_PERSIST=1 nautilus --gapplication-service";
      readiness.waitDbus = "org.gnome.NautilusPortal";
    };
  };
}
