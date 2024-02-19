{ ... }:
{
  sane.programs.portfolio-filemanager = {
    # this is all taken pretty directly from nautilus config
    sandbox.method = "bwrap";
    sandbox.wrapperType = "inplace";
    sandbox.whitelistDbus = [ "user" ];  # for portals launching apps
    sandbox.whitelistWayland = true;
    sandbox.extraHomePaths = [
      # grant access to pretty much everything, except for secret keys.
      # ".cache"
      # ".config"
      # ".local"
      "archive"
      "Books"
      "dev"
      "knowledge"
      "Music"
      "nixos"
      "Pictures"
      # "private"  #< explicitly NOT
      "records"
      "ref"
      "tmp"
      "use"
      "Videos"
    ];
    sandbox.extraPaths = [
      "/boot"
      "/mnt"
      # "nix"
      "/run/media"  # for mounted devices
      "/tmp"
      "/var"
    ];
    sandbox.extraRuntimePaths = [
      # not sure if these are actually necessary
      "gvfs"
      "gvfsd"
    ];

    mime.priority = 160;  #< default is 100, so higher means we fall-back to other apps that might be more specialized
    mime.associations = {
      "inode/directory" = "dev.tchx84.Portfolio.desktop";
    };
  };
}
