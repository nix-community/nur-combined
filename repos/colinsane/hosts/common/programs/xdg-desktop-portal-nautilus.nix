{ pkgs, ... }:
{
  sane.programs.xdg-desktop-portal-nautilus = {
    packageUnwrapped = pkgs.rmDbusServices (pkgs.nautilus.overrideAttrs (upstream: {
      postPatch = (upstream.postPatch or "") + ''
        cp data/icons/hicolor/scalable/apps/org.gnome.Nautilus.svg data/icons/hicolor/scalable/apps/org.gnome.NautilusPortal.svg
        # XXX: org.gnome.NautilusPreviewer is an optional integration provided by `sushi` (installed separately).
        # press spacebar when a media file is selected to preview it (in a very speedy viewer).
        # however when using Nautilus as a x-d-p FileChooser, the previewer opens below the file chooser and isn't so helpful.
        substituteInPlace src/nautilus-previewer.c \
          --replace-fail org.gnome.NautilusPreviewerDevel org.gnome.NautilusPreviewerPortal
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
    sandbox.mesaCacheDir = ".cache/xdg-desktop-portal-nautilus/mesa";  # TODO: is this the correct app-id?

    services.xdg-desktop-portal-nautilus = {
      description = "xdg-desktop-portal-nautilus backend (provides file chooser for xdg-desktop-portal)";
      dependencyOf = [ "xdg-desktop-portal" ];

      # NAUTILUS_PERSIST, else --gapplication-service means nautilus exits after 10s of inactivity
      command = "env NAUTILUS_PERSIST=1 nautilus --gapplication-service";
      readiness.waitDbus = "org.gnome.NautilusPortal";
    };
  };
}
