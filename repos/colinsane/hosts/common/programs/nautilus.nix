{ pkgs, ... }:
{
  sane.programs."nautilus" = {
    # some of its dbus services don't even refer to real paths
    packageUnwrapped = pkgs.rmDbusServicesInPlace (pkgs.nautilus.overrideAttrs (orig: {
      # enable the "Audio and Video Properties" pane. see: <https://nixos.wiki/wiki/Nautilus>
      buildInputs = orig.buildInputs ++ (with pkgs.gst_all_1; [
        gst-plugins-good
        gst-plugins-bad
      ]);
    }));

    # suggestedPrograms = [
    #   "gvfs"  # browse ftp://, etc  (TODO: fix!)
    # ];

    sandbox.whitelistDbus.user = true;  #< TODO: reduce  # for portals launching apps
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
      "/mnt/flowy"
      # "/mnt/lappy"
      "/mnt/moby"
      "/mnt/servo"
      # "nix"
      "/run/media"  # for mounted devices
      "/tmp"
      "/var"
    ];
    # sandbox.extraRuntimePaths = [
    #   # not sure if these are actually necessary
    #   "gvfs"
    #   "gvfsd"
    # ];

    mime.priority = 150;  #< default is 100, so higher means we fall-back to other apps that might be more specialized
    mime.associations = {
      "inode/directory" = "org.gnome.Nautilus.desktop";
    };
  };
}
