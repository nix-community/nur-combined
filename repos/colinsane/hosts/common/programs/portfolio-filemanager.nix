{ ... }:
{
  sane.programs.portfolio-filemanager = {
    # this is all taken pretty directly from nautilus config
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
      "/mnt/lappy"
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
    sandbox.mesaCacheDir = ".cache/portfolio/mesa";  # TODO: is this the correct app-id?

    # suggestedPrograms = [ "gvfs" ];  #< TODO: fix (ftp:// share, USB drive browsing)

    mime.priority = 160;  #< default is 100, so higher means we fall-back to other apps that might be more specialized
    mime.associations = {
      "inode/directory" = "dev.tchx84.Portfolio.desktop";
    };
  };
}
